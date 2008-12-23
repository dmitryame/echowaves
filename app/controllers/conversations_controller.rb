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
    #should also remove the users if they were already invited
    existing_invites = Invite.find(:all, :conditions => ["requestor_id = ? and conversation_id = ?", current_user.id, @conversation.id ] ).map {|invite| invite.conversation}
    @friends_convos = current_user.friends_convos - existing_invites
    
    render :layout => "invite"
  end
  
  def invite_from_list
    @user_id = params[:user_id]
    #TODO this preferenbly should move into the model
    existing_invite = Invite.find(:first, :conditions => ["user_id = ? and requestor_id = ? and conversation_id = ?", @user_id, current_user.id, params[:id] ] )
    return if(existing_invite != nil)#don't do anything, already invited
    @invite = Invite.new
    @invite.user_id = @user_id
    @invite.requestor = current_user
    @invite.conversation_id = params[:id]
    @invite.save    
  end

end
