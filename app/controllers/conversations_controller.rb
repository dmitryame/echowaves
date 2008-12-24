class ConversationsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :auto_complete_for_conversation_name, :complete_name ]
  after_filter :store_location, :only => [:index, :new]  
  
  auto_complete_with_scope_for 'published', :conversation, :name # multiple scopes can be chained like 'published.readonly'

  def complete_name
    @conversation = Conversation.published.find_by_name(params[:id])
    redirect_to conversation_messages_path(@conversation)
  end

  def index    
    @conversations = Conversation.published.not_personal.paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @conversations }
    end
  end

  def show
    @conversation = Conversation.published.find(params[:id])
    redirect_to(conversation_messages_path(@conversation))  
  end

  def new
    @conversation = Conversation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @conversation }
    end
  end

  def create
    @conversation = Conversation.new(params[:conversation])
    
    respond_to do |format|
      if current_user.conversations << @conversation
        flash[:notice] = 'Conversation was successfully created.'
        format.html { redirect_to(@conversation) }
        format.xml  { render :xml => @conversation, :status => :created, :location => @conversation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @conversation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def follow
    @conversation = Conversation.published.find(params[:id])
    current_user.follow(@conversation)
  end

  def unfollow
    @conversation = Conversation.published.find(params[:id])
    current_user.unfollow(@conversation)
  end

  def follow_from_list
    follow
  end
  
  def unfollow_from_list
    unfollow
  end

  def readwrite_status
    read_only = (params[:mode] == 'rw') ? false : true 
    @conversation = Conversation.published.find( params[:id] )
    @conversation.update_attributes( :read_only => read_only ) if ( @conversation.owner == current_user )
    redirect_to conversation_messages_path( @conversation )
  end

  def report
    conversation = Conversation.published.find(params[:id])
    conversation.report_abuse(current_user)
    # FIXME: refactor this or simplify if do not need to degrade if there is no javascript
    # what to do with the other users currently in this conversation if is disabled?
    if conversation.disabled_by_abuse_report?
      if request.xhr?
        render :update do |page|
          page.redirect_to(conversations_path)
        end
      else
        redirect_to conversations_path
      end
    else
      render(:nothing => true)
    end
  end
  
  def invite
    @conversation = Conversation.published.find(params[:id])
    @friends = current_user.friends    
    #should also remove the users if they were already invited
    @friends.delete_if do |user|
      invite_for_user = Invite.find(:first, :conditions => ["user_id = ? and conversation_id = ?", user.id, @conversation.id ] )
      true unless invite_for_user == nil
    end
    #should also remove the users that already follow proposed convo
    # @friends.delete_if do |user|
    #   user.conversations.detect {|convo| convo.id == @conversation.id}
    # end


    render :layout => "invite"
  end
  
  def invite_from_list
    current_user.friends.each do |user| 
      @user = user if(user.id.to_s == params[:user_id]) #search for the user in friends collection
    end
    #TODO this whole thing preferebly should move into the model
    existing_invite = Invite.find(:first, :conditions => ["user_id = ? and requestor_id = ? and conversation_id = ?", @user.id, current_user.id, params[:id] ] )
    return if(existing_invite != nil)#don't do anything, already invited
    @invite = Invite.new
    @invite.user_id = @user.id
    @invite.requestor = current_user
    @invite.conversation_id = params[:id]
    @invite.save    
    
    #now let's create a system message and send it to the convo channel
    msg = " invites you to follow a convo: <a href='/conversations/#{params[:id]}/messages'>#{@invite.conversation.name}</a>"
    notification = current_user.messages.create( :conversation => @user.personal_conversation, :message => msg, :system_message => true)
    notification.save
    send_stomp_message(notification)

    render :update do |page| 
      page["user_" + @user.id.to_s].visual_effect :drop_out
    end 
  end
  
  private
  # FIXME: this is redundunt method from the messages_controller, this has to be addressed
  def send_stomp_message(message)
    newmessagescript = render_to_string :partial => 'messages/message', :object => message
    s = Stomp::Client.new
    s.send("CONVERSATION_CHANNEL_" + message.conversation.id.to_s, newmessagescript)
    s.close
  rescue SystemCallError
    logger.error "IO failed: " + $!
    # raise
  end

end
