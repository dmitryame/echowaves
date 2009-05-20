class ConversationsController < ApplicationController
  
  public :render_to_string # this is needed to make render_to_string public for message model to be able to use it
  
  before_filter :login_or_oauth_required, :except => [:index, :show, :auto_complete_for_conversation_name, :complete_name ]                                            
  before_filter :find_conversation, :except => [:bookmarked, :complete_name, :create, :spawn, :new, :index]
  before_filter :check_read_access, :only => [:show]
  
  after_filter :store_location, :only => [:show, :new]
  
  auto_complete_for :conversation, :name # multiple scopes can be chained like 'published.readonly'
  # auto_complete_for :tag, :name

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

  def show
    @messages = @conversation.messages.published.find(:all, :include => [:user], :limit => 50, :order => 'id DESC').reverse
    
    if logged_in?
      subscription = current_user.subscriptions.find_by_conversation_id(@conversation.id)
      @last_message_id = subscription.last_message_id if (subscription && subscription.new_messages_count > 0)
    end

    @has_more_messages = @conversation.has_messages_before?(@messages.first)

    respond_to do |format|
      format.html { render :layout => 'messages' }
      format.xml  { render :xml => {:conversation => @conversation, :messages => @messages} }
      format.js   do
        data = []
        @messages.group_by(&:date).each do |date, grouped_messages|
        	group = { :date => date }
        	group.merge!({ :messages => grouped_messages.map { |message| message.data_for_templates } })
        	data << group
        end
        # mark all the messages as read AFTER the ajax request for the messages list
        current_user.conversation_visit_update(@conversation) if logged_in?
        render :text => {:message_groups => data, :last_message_id => @last_message_id}.to_json
      end
    end
  end

  def files
    @messages = @conversation.messages.with_file.published.find(:all, :include => [:user], :limit => 50, :order => 'id DESC').reverse
    
    if logged_in?
      subscription = current_user.subscriptions.find_by_conversation_id(@conversation.id)
      @last_message_id = subscription.last_message_id if (subscription && subscription.new_messages_count > 0)
      current_user.conversation_visit_update(@conversation)
    end

    @has_more_messages = @conversation.has_messages_before?(@messages.first)

    respond_to do |format|
      format.html { render :layout => 'messages' }
      format.xml  { render :xml => @conversation }
    end
  end
  
  def images
    @messages = @conversation.messages.with_image.published.find(:all, :include => [:user], :limit => 50, :order => 'id DESC').reverse
    
    if logged_in?
      subscription = current_user.subscriptions.find_by_conversation_id(@conversation.id)
      @last_message_id = subscription.last_message_id if (subscription && subscription.new_messages_count > 0)
      current_user.conversation_visit_update(@conversation)
    end

    @has_more_messages = @conversation.has_messages_before?(@messages.first)

    respond_to do |format|
      format.html { render :layout => 'messages' }
      format.xml  { render :xml => @conversation }
    end
  end
  
  def new
    @conversation = Conversation.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @conversation }
    end
  end

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
  
  def create
    @conversation = Conversation.new(params[:conversation])
    
    respond_to do |format|
      if current_user.conversations << @conversation
        flash[:notice] = t("conversations.convo_sucesfully_created")
        
        if @conversation.spawned?
          # create a message in the original conversation notifying about this spawning
          # and send realtime notification to everyone who's listening
          notification_message = @conversation.notify_of_new_spawn( current_user )
          notification_message.send_stomp_message unless notification_message == nil
          # copy the original message in the recient create convo
          @copied_message = @conversation.parent_message.clone
          @copied_message.conversation = @conversation
          @copied_message.save
          # now add the attachment markup to the copied message if the original message has an attachment
          @copied_message.message_html = @copied_message.message_html + attachment_markup(@conversation.parent_message) if @conversation.parent_message.has_attachment?            
          @copied_message.save
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
            notification.send_stomp_message
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

  def follow
    current_user.follow(@conversation)
  end
  
  def follow_with_token
    current_user.follow(@conversation, params[:token])
    redirect_to @conversation
  end
  
  def follow_from_list
    follow
  end
  
  def unfollow
    current_user.unfollow(@conversation)
  end

  def unfollow_from_list
    unfollow
  end

  def remove_user
    if @conversation.private? && @conversation.owner == current_user && !params[:user_id].blank?
      @user = User.find(params[:user_id])
      @user.unfollow(@conversation)
    end
  end
  
  def readwrite_status
    read_only = (params[:mode] == 'rw') ? false : true 
    @conversation.update_attributes( :read_only => read_only ) if ( @conversation.owner == current_user )
    redirect_to conversation_path( @conversation )
  end

  def private_status
    private_status = (params[:mode] == 'public') ? false : true 
    @conversation.update_attributes( :private => private_status ) if ( @conversation.owner == current_user )
    redirect_to conversation_path( @conversation )
  end
    
  def invite
    if @conversation.private? && @conversation.owner != current_user
      flash[:error] = t("errors.only_the_owner_can_invite")
      redirect_to conversation_path(@conversation)
    else
      @friends = current_user.friends    
      # should also remove the users if they were already invited
      @friends.delete_if do |user|
        invite_for_user = Invite.find(:first, :conditions => ["user_id = ? and conversation_id = ?", user.id, @conversation.id ] )
        true unless invite_for_user == nil
      end
      # should also remove the users that already follow proposed convo
      # @friends.delete_if do |user|
      #   user.conversations.detect {|convo| convo.id == @conversation.id}
      # end
      # render :layout => "invite"
    end
  end
  
  def invite_from_list
    current_user.friends.each do |user| 
      @user = user if(user.id.to_s == params[:user_id]) # search for the user in friends collection
    end
    # TODO this whole thing preferebly should move into the model
    existing_invite = Invite.find(:first, :conditions => ["user_id = ? and requestor_id = ? and conversation_id = ?", @user.id, current_user.id, params[:id] ] )
    return if(existing_invite != nil) # don't do anything, already invited
    @invite = Invite.new
    @invite.user_id = @user.id
    @invite.requestor = current_user
    @invite.conversation_id = params[:id]
    @invite.token = @user.perishable_token if @conversation.private?
    @invite.save
    
    if @conversation.private?
      # private convo only sends invite via email
      @user.deliver_private_invite_instructions!(@invite)
    else
      @user.deliver_public_invite_instructions!(@invite)
      # now let's create a system message and send it to the convo channel
      # TODO: how to translate this for the current user?
      msg = " invites you to follow a convo: <a href='/conversations/#{params[:id]}'>#{@invite.conversation.name}</a>"
      notification = current_user.messages.create( :conversation => @user.personal_conversation, :message => msg)
      notification.system_message = true
      notification.save
      notification.send_stomp_message
    end
    
    render :update do |page| 
      page["user_" + @user.id.to_s].visual_effect :drop_out
    end 
  end

  def toogle_bookmark
    if @conversation.tag_list_on(:bookmarks).include?(current_user.bookmark_tag)
      @conversation.tag_list_on(:bookmarks).remove(current_user.bookmark_tag)
      @conversation.save
    else
      current_user.tag(@conversation, :with => @conversation.bookmarks.collect{|tag| tag.name}.join(", ")  + ", " + current_user.bookmark_tag, :on => :bookmarks)
    end
  end
  
  def bookmarked
    @conversations = Conversation.tagged_with(current_user.bookmark_tag, :on => :bookmarks).paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html
      format.atom
      format.xml { render :xml => @conversations }
    end
  end
  
  # def add_tag
  #   current_user.tag(@conversation, :with => @conversation.tags.collect{|tag| tag.name}.join(", ")  + ", " + params[:tag][:name].to_s, :on => :tags)
  # end
  # 
  # def remove_tag
  #   @conversation.tag_list.remove(params[:tag])
  #   @conversation.save    
  # end

  # TODO: remove this thing
  def complete_name
    @conversation = Conversation.find_by_name(params[:id])
    redirect_to conversation_path(@conversation)
  end
  
private

  def find_conversation
    @conversation = Conversation.find( params[:id] )
  end
  
  def check_read_access
    unless @conversation.readable_by?(current_user) || !@conversation.private?
      flash[:error] = "Sorry, this is a private conversation. You can try anoter one"
      redirect_to conversations_path
      return
    end
  end
  
  def attachment_markup(message)
    if message.has_image?
      %Q( <div class="img_attachment"><a href="#{message.attachment.url}"><img src="#{message.attachment.url(:big)}" alt="#{message.message}"/></a></div> )
    elsif message.has_pdf?
      %Q( <div class="file_attachment"><a href="#{message.attachment.url}"><img src="/images/icons/pdf_large.jpg" alt="PDF Document" width="100" /></a></div> )
    elsif message.has_zip?
      %Q( <div class="file_attachment"><a href="#{message.attachment.url}"><img src="/images/icons/zip_large.jpg" alt="ZIP File" width="82" /></a></div> )
    end
  end
end