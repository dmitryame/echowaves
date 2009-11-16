class ConversationsController < ApplicationController

  before_filter :login_or_oauth_required,
    :except => [:index, :show, :followers, :auto_complete_for_conversation_name, :complete_name]
  before_filter :find_conversation,
    :except => [:bookmarked, :complete_name, :create, :spawn, :new, :index, :new_messages, :toogle_readwrite_status, :toogle_private_status]
  before_filter :check_read_access, :only => [:show, :followers]
  after_filter :store_location, :only => [:show, :new]

  auto_complete_for :conversation, :name # multiple scopes can be chained like 'published.readonly'
  # auto_complete_for :tag, :name

  #----------------------------------------------------------------------------
  def index
    if params[:tag] != nil
      @conversations = Conversation.tagged_with(params[:tag], :on => :tags).non_private.paginate :page => params[:page], :order => 'created_at DESC'
    else
      @conversations = Conversation.non_private.paginate :page => params[:page], :order => 'created_at DESC'
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

  #----------------------------------------------------------------------------
  def followers
    @followers = @conversation.users
    respond_to do |format|
      format.html# { render :layout => 'users' }
      format.xml  { render :xml => {:followers => @followers} }
    end
  end

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
          # copy the original message in the recient create convo
          copied_message = @conversation.parent_message.clone
          copied_message.conversation = @conversation
          copied_message.save
          # now add the attachment markup to the copied message if the original message has an attachment
          copied_message.message_html = @conversation.parent_message.attachment_markup + copied_message.message_html if @conversation.parent_message.has_attachment?
          copied_message.save
        end

        # now let's force all the creator's followers to follow the convo
        # unless the conversation is private
        unless @conversation.private?
          if USE_WORKLING
            EchowavesWorker.asynch_force_followers_to_follow_new_convo(:user_id => current_user.id, :conversation_id => @conversation.id)
            EchowavesWorker.asynch_notify_followers_about_new_convo(:user_id => current_user.id, :conversation_id => @conversation.id)
          else # painfully slow if the user has many followers
            current_user.followers.each do |u|
              u.follow @conversation # force all my followers to follow my new convo
              u.deliver_notification_about_new_convo!(@conversation.id, current_user.id)
            end
          end
          # notify everyone!
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
    current_user.follow(@conversation, params[:token])
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
    @conversation = Conversation.find(params[:id])
    read_only = (params[:mode] == 'rw') ? false : true
    @conversation.update_attributes( :read_only => read_only ) if ( @conversation.owner == current_user )
    redirect_to conversation_path( @conversation )
  end

  #----------------------------------------------------------------------------
  def toogle_private_status
    @conversation = Conversation.find(params[:id])
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
      @users = current_user.followers
      # should also remove the users if they were already invited or the users already follow the convo
      @users.delete_if do |user|
        true if !user.can_be_invited_to?(@conversation, current_user)
      end
    end
  end

  #----------------------------------------------------------------------------
  def invite_from_list
    @user = User.active.find(params[:user_id])
    @user.invite( @conversation, current_user ) # if @user.friend_of?( current_user )
    render :update do |page|
      page["user_" + @user.id.to_s].visual_effect :drop_out
    end
  end

  #----------------------------------------------------------------------------
  def invite_all_my_followers
    if USE_WORKLING
      EchowavesWorker.asynch_invite_followers_to_new_convo(:user_id => current_user.id, :conversation_id => @conversation.id)
    else # painfully slow if the user has many followers
      #invite all my followers, if the convo is public
      current_user.followers.each do |u|
        # next  if ( @conversation && @conversation.parent_message && personal_convo == @conversation.parent_message.conversation )
        u.invite @conversation, current_user unless @conversation.users.include?(user)
      end
    end
    render :update do |page|
      page["spinner_x"].visual_effect :drop_out
    end
  end

  #----------------------------------------------------------------------------
  def invite_via_email
    emails_string = params[:emails]
    emails_string.to_s.split(/(,| |\r\n|\n|\r)/).each do |email|
      if(email =~ EMAIL_REGEX)
        # here we've got a valid email address lets send the invite
        # first lets see if the email belongs to an existing user
        @existing_user = User.active.find_by_email(email)
        if @existing_user.present?
          @existing_user.invite( @conversation, current_user )
        else # the email does not belongs to any existing user
          invite = Invite.new
          # invite.user_id = self.id
          invite.requestor = current_user
          invite.conversation_id = @conversation.id
          invite.token = Authlogic::Random::friendly_token
          invite.save
          # send the invite by email
          if USE_WORKLING
            EchowavesWorker.asynch_deliver_email_invite(:email => email, :invite_id => invite.id)
          else
            UserMailer.deliver_email_invite(email, invite)
          end
        end
      end
    end
    render :update do |page|
      page["spinner_y"].visual_effect :drop_out
      page["emails_"].clear
      # FIXME: drop the user if the user is in the page
      # page["user_" + @existing_user.id.to_s].visual_effect :drop_out if @existing_user.present?
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
    @conversation = Rails.cache.fetch('conversation_'+params[:id], :expires_in => 24.hours) {Conversation.find( params[:id] )}
  end

  #----------------------------------------------------------------------------
  def check_read_access
    unless @conversation.readable_by?(current_user) || @conversation.public?
      flash[:error] = "Sorry, this is a private conversation. You can try anoter one"
      redirect_to conversations_path
    end
  end

end
