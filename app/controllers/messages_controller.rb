require 'stomp'

class MessagesController < ApplicationController
  
  public :render_to_string # this is needed to make render_to_string public for message model to be able to use it
  
  before_filter :login_required, :except => [:index, :show, :get_more_messages ]
  before_filter :find_conversation, :except => [ :send_data, :auto_complete_for_tag_name]
  before_filter :check_write_access, :only => [ :create ]
  after_filter :store_location, :only => [:index]  

  auto_complete_for :tag, :name
  
  def index
    @messages = @conversation.messages.published.find(:all, :include => [:user], :limit => 100, :order => 'id DESC').reverse
    current_user.conversation_visit_update(@conversation) if logged_in?
    
    @has_more_messages = @conversation.has_messages_before?(@messages.first)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  #TODO: get_more_messages, get_more_messages_on_top, get_more_messages_on_bottom need to be refactored into something more generic
  def get_more_messages
    @messages = @conversation.get_messages_before(params[:before]).reverse
    @has_more_messages = @conversation.has_messages_before?(@messages.first)
  end

  def get_more_messages_on_top
    @messages = @conversation.get_messages_before(params[:before]).reverse
    @has_more_messages_on_top = @conversation.has_messages_before?(@messages.first)
  end

  def get_more_messages_on_bottom
    @messages = @conversation.get_messages_after(params[:after]).reverse
    @has_more_messages_on_bottom = @conversation.has_messages_after?(@messages.last)
  end

  def show
    @message = Message.published.find(params[:id])
    @messages = Array[@message] 
    
    @has_more_messages_on_top    = @conversation.has_messages_before?(@message)
    @has_more_messages_on_bottom = @conversation.has_messages_after?(@message)
    
    respond_to do |format|
      format.html { render :layout => "single_message" }
      format.xml  { render :xml => @message }
    end
  end

  def create
    @message = @conversation.messages.new(params[:message])
    
    respond_to do |format|
      if current_user.messages << @message
        format.html { redirect_to(conversation_messages_path(@conversation)) }
        format.xml { render :xml => @message, :status => :created, :location => @message }
        format.js {
          # send a stomp message for everyone else to pick it up
          @message.send_stomp_message(self)
          render :nothing => true
        }
      else
        format.html { render :nothing => true }
        format.xml { render :xml => @message.errors, :status => :unprocessable_entity }
        format.js { render :nothing => true }
      end
    end
  end

  def upload_attachment
    render( :nothing => true ) and return if params[:message][:attachment].blank?

    @message = current_user.messages.new(params[:message])
    @message.message = @message.attachment_file_name if @message.message.blank?

    if @conversation.messages << @message
      # send a stomp message for everyone else to pick it up
      @message.send_stomp_message(self)
    end
    # FIXME: this not work yet, because we are calling this action from an iframe,
    # and the RJS can't access the document.
    # We need something like respond_to_parent plugin, but this plugin don't work with safari 3
    # right now.
    # This will be useful for fix issue #1, and for reset the forms AFTER upload an
    # attachment
    #
    # render :action => 'upload_attachment.js.rjs'
    
    render :nothing => true
  end

  def report
    message = @conversation.messages.find(params[:id])
    message.report_abuse(current_user)
    render :nothing => true
  end

  # def spawn_conversation
  #   @message = Message.find(params[:id])
  # 
  #   if current_user.conversations.find_by_parent_message_id( @message.id )
  #     flash[:error] = "You already spawned a new conversation from this message."
  #     redirect_to conversation_messages_path(@conversation)
  #     return
  #   end
  #   
  #   spawned_conversation = @message.spawn_new_conversation( current_user )
  #   
  #   # create a message in the original conversation notifying about this spawning
  #   # and send realtime notification to everyone who's listening
  #   notification_message = @conversation.notify_of_new_spawn( current_user, spawned_conversation, @message )
  #   notification_message.send_stomp_message(self) unless notification_message == nil
  #       
  #   redirect_to conversation_messages_path(spawned_conversation)
  # end
  
  private

  def find_conversation
    @conversation = Conversation.published.find( params[:conversation_id] )
  end
  
  def check_write_access
    unless @conversation.writable_by?(current_user)
      flash[:error] = t("conversations.not_allowed_to_write_warning")
      redirect_to conversation_messages_path(@conversation)
      return
    end
  end
  
  # def send_stomp_message(message)
  #   newmessagescript = render_to_string :partial => 'message', :object => message
  #   s = Stomp::Client.new
  #   s.send("CONVERSATION_CHANNEL_" + params[:conversation_id], newmessagescript)
  #   s.close
  # rescue SystemCallError
  #   logger.error "IO failed: " + $!
  #   # raise
  # end
  
  # def send_stomp_notifications
  #   s = Stomp::Client.new
  #   s.send("CONVERSATION_NOTIFY_CHANNEL_" + params[:conversation_id], "1")
  #   # puts ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CONVERSATION_NOTIFY_CHANNEL_" + params[:conversation_id])
  #   s.close
  # rescue SystemCallError
  #   logger.error "IO failed: " + $!
  #   # raise
  # end
  
end
