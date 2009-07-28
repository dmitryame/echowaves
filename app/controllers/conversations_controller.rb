class ConversationsController < ApplicationController
  
  public :render_to_string # this is needed to make render_to_string public for message model to be able to use it
  
  before_filter :login_or_oauth_required, :except => [:index, :show, :auto_complete_for_conversation_name, :complete_name]                                            
  before_filter :find_conversation, :except => [:bookmarked, :complete_name, :create, :spawn, :new, :index, :new_messages]
  before_filter :check_read_access, :only => [:show]
  
  after_filter :store_location, :only => [:show, :new]
  
  auto_complete_for :conversation, :name # multiple scopes can be chained like 'published.readonly'
  # auto_complete_for :tag, :name

  #----------------------------------------------------------------------------
  def index
    if params[:tag] != nil
      @conversations = Conversation.tagged_with(params[:tag], :on => :tags).non_private.paginate :page => params[:page], :order => 'created_at DESC'
    else
      @conversations = Conversation.non_private.not_personal.paginate :page => params[:page], :order => 'created_at DESC'
    end
    respond_to do |format|
      format.html
      format.atom
      format.xml { render :xml => @conversations }
    end
  end

  #----------------------------------------------------------------------------
  def show
    @has_more_messages = @conversation.messages.published.count > Message::PER_PAGE # the number of messages loaded in a convo
    @last_message_id = @conversation.messages.published.first(:offset => Message::PER_PAGE-1, :order => 'id DESC').id if @has_more_messages
    respond_to do |format|
      format.html { render :layout => 'messages' }
      format.xml  { render :xml => {:conversation => @conversation, :messages => @messages} }
    end
  end

  alias_method :images, :show
  alias_method :files, :show
  alias_method :system_messages, :show
  
  #----------------------------------------------------------------------------
  def new
    @conversation = Conversation.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @conversation }
    end
  end
  
  #----------------------------------------------------------------------------
  def spawn
    @conversation = Conversation.new
    if params[:message_id]
      @message = Message.find(params[:message_id])

      if current_user.conversations.find_by_parent_message_id( @message.id )
        flash[:error] = t("conversations.already_spawned_warning")
        redirect_to conversation_path(@message.conversation_id)
        return
      end

      @conversation.parent_message_id = @message.id
      @conversation.description = %Q(
#{ t( "conversations.user_spawned_convo_description", :login => current_user.login, :original_message_link => conversation_message_url(@message.conversation_id, @message) ) }
      )
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @conversation }
    end
  end
  
  #----------------------------------------------------------------------------
  def create
    @conversation = Conversation.new(params[:conversation])
    
    respond_to do |format|
      if current_user.conversations << @conversation
        flash[:notice] = t("conversations.convo_sucesfully_created")
        
        if @conversation.spawned?
          # create a message in the original conversation notifying about this spawning
          # and send realtime notification to everyone who's listening
          notification_message = @conversation.notify_of_new_spawn( current_user )
          notification_message.send_to_msg_broker unless notification_message == nil
          # copy the original message in the recient create convo
          copied_message = @conversation.parent_message.clone
          copied_message.conversation = @conversation
          copied_message.save
          # now add the attachment markup to the copied message if the original message has an attachment
          copied_message.message_html = copied_message.message_html + attachment_markup(@conversation.parent_message) if @conversation.parent_message.has_attachment?            
          copied_message.save
        else # create a first message that is the same as the convo description
          message = current_user.messages.create!( :conversation => @conversation, :message => @conversation.description)
        end
        
        # now let's create a system message and send it to the the creator's followers
        # unless the conversation is private
        unless @conversation.private?
          current_user.followers_convos.each do |personal_convo|
            next  if ( @conversation && @conversation.parent_message && personal_convo == @conversation.parent_message.conversation )
            # TODO: how to translate this for the current user?
            msg = " created a new convo: <a href='/conversations/#{@conversation.id}'>#{@conversation.name}</a>"
            notification = current_user.messages.create( :conversation => personal_convo, :message => msg)
            notification.system_message = true
            notification.save
            notification.send_to_msg_broker
          end
        end
        
        format.html { redirect_to(@conversation) }
        format.xml  { render :xml => @conversation, :status => :created, :location => @conversation }
      else
        format.html do
          if @conversation.parent_message_id.blank?
            render( :action => "new" )
          else
            @message = @conversation.parent_message
            render( :action => "spawn" )
          end
        end
        format.xml  { render :xml => @conversation.errors, :status => :unprocessable_entity }
      end
    end
  end

  #----------------------------------------------------------------------------
  def follow
    current_user.follow(@conversation)
  end
  
  #----------------------------------------------------------------------------
  def follow_with_token
    current_user.follow(@conversation, params[:token])
    redirect_to @conversation
  end

  #----------------------------------------------------------------------------
  def follow_email_with_token
    # resolve invite
    invite = Invite.find_by_conversation_id_and_token(params[:id], params[:token].to_s)        
    invite.update_attribute( :user_id, current_user.id)
    
    current_user.follow(@conversation, params[:token].to_s)
    redirect_to @conversation
  end
  
  #----------------------------------------------------------------------------
  def follow_from_list
    follow
  end
  
  #----------------------------------------------------------------------------
  def unfollow
    current_user.unfollow(@conversation)
  end

  #----------------------------------------------------------------------------
  def unfollow_from_list
    unfollow
  end

  #----------------------------------------------------------------------------
  def remove_user
    if @conversation.private? && @conversation.owner == current_user && !params[:user_id].blank?
      @user = User.find(params[:user_id])
      @user.unfollow(@conversation)
    end
  end
  
  #----------------------------------------------------------------------------
  def toogle_readwrite_status
    read_only = (params[:mode] == 'rw') ? false : true 
    @conversation.update_attributes( :read_only => read_only ) if ( @conversation.owner == current_user )
    redirect_to conversation_path( @conversation )
  end

  #----------------------------------------------------------------------------
  def toogle_private_status
    private_status = (params[:mode] == 'public') ? false : true 
    @conversation.update_attributes( :private => private_status ) if ( @conversation.owner == current_user )
    redirect_to conversation_path( @conversation )
  end
  
  #----------------------------------------------------------------------------  
  def invite
    if @conversation.private? && @conversation.owner != current_user
      flash[:error] = t("errors.only_the_owner_can_invite")
      redirect_to conversation_path(@conversation)
    else
      @friends = current_user.friends    
      # should also remove the users if they were already invited or the users already follow the convo
      @friends.delete_if do |user|
        true if !user.can_be_invited_to?(@conversation, current_user) || @conversation.users.include?(user)
      end
    end
  end
  
  #----------------------------------------------------------------------------
  def invite_from_list
    @user = User.active.find(params[:user_id])    
    @user.invite( @conversation, current_user ) if @user.friend_of?( current_user )
    render :update do |page| 
      page["user_" + @user.id.to_s].visual_effect :drop_out
    end 
  end

  #----------------------------------------------------------------------------
  def invite_all_my_followers
    current_user.followers.each do |user| 
      user.invite @conversation, current_user unless !@conversation.users.include?(user)
    end
    render :update do |page| 
      page["spinner_0"].visual_effect :drop_out
    end 
  end

  #----------------------------------------------------------------------------
  def invite_via_email
    emails_string = params[:emails]        
    emails_string.to_s.split(/(,| |\r\n|\n|\r)/).each do |email|    
      if(email =~ EMAIL_REGEX)
        # here we've got a valid email address lets send the invite
        # existing_invite = Invite.find(:first, :conditions => ["user_id = ? and requestor_id = ? and conversation_id = ?", self.id, invitee.id, conversation.id ] )
        #         return if(existing_invite != nil) # don't do anything, already invited
        invite = Invite.new
        # invite.user_id = self.id
        invite.requestor = current_user
        invite.conversation_id = @conversation.id
        invite.token = Authlogic::Random::friendly_token
        invite.save
        # send the invite by email
        if USE_WORKLING
          MailerWorker.asynch_deliver_email_invite(:email => email, :invite_id => invite.id)
        else
          UserMailer.deliver_email_invite(email, invite)
        end               
      end
    end    
    render :update do |page| 
      page["spinner_1"].visual_effect :drop_out
      page["emails_"].clear
    end 
  end

  #----------------------------------------------------------------------------
  def toogle_bookmark
    if @conversation.tag_list_on(:bookmarks).include?(current_user.bookmark_tag)
      @conversation.tag_list_on(:bookmarks).remove(current_user.bookmark_tag)
      @conversation.save
    else
      current_user.tag(@conversation, :with => @conversation.bookmarks.collect{|tag| tag.name}.join(", ")  + ", " + current_user.bookmark_tag, :on => :bookmarks)
    end
  end

  #----------------------------------------------------------------------------
  def bookmarked
    @conversations = Conversation.tagged_with(current_user.bookmark_tag, :on => :bookmarks).paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html
      format.atom
      format.xml { render :xml => @conversations }
    end
  end
  
  # temporary removed feature
  #----------------------------------------------------------------------------
  # def add_tag
  #   current_user.tag(@conversation, :with => @conversation.tags.collect{|tag| tag.name}.join(", ")  + ", " + params[:tag][:name].to_s, :on => :tags)
  # end
  # 
  # def remove_tag
  #   @conversation.tag_list.remove(params[:tag])
  #   @conversation.save    
  # end
  
  #----------------------------------------------------------------------------
  def new_messages
    @news = current_user.news
    respond_to do |format|
      format.html do
        headers["Status"] = "403 Forbidden"
        redirect_to(conversations_url)
      end      
      format.xml do
        render :xml => @news.to_xml(
                         :except => [:id, :activated_at, :created_at, :updated_at, :last_message_id, :user_id],
                         :methods => [:new_messages_count, :convo_name])
      end
      format.json do
        render :json => @news.to_json(
                         :except => [:id, :activated_at, :created_at, :updated_at, :last_message_id, :user_id],
                         :methods => [:new_messages_count, :convo_name])
      end
      format.atom
    end
  end
    
private

  #----------------------------------------------------------------------------
  def find_conversation
    @conversation = Conversation.find( params[:id] )
  end
  
  #----------------------------------------------------------------------------
  def check_read_access
    unless @conversation.readable_by?(current_user) || @conversation.public?
      flash[:error] = "Sorry, this is a private conversation. You can try anoter one"
      redirect_to conversations_path
      return
    end
  end
  
  #----------------------------------------------------------------------------
  def attachment_markup(message)
    if message.has_image?
      %Q( <div class="img_attachment"><a href="#{message.attachment.url}" style="display:block;height:#{message.attachment_height+40}px;with:#{message.attachment_width+40}px;"><img src="#{message.attachment.url(:big)}" alt="#{message.message}" height="#{message.attachment_height}" width="#{message.attachment_width}" /></a></div> )
    elsif message.has_pdf?
      %Q( <div class="file_attachment"><a href="#{message.attachment.url}" style="display:block;height:100px;"><img src="/images/icons/pdf_large.jpg" alt="PDF Document" height="100" /></a></div> )
    elsif message.has_zip?
      %Q( <div class="file_attachment"><a href="#{message.attachment.url}" style="display:block;height:99px;"><img src="/images/icons/zip_large.jpg" alt="ZIP File" height="99" /></a></div> )
    end
  end

end