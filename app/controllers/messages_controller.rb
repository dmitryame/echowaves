require 'stomp'

class MessagesController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :get_more_messages ]
  before_filter :find_conversation, :except => :send_data
  before_filter :check_write_access, :only => [ :create ]
  after_filter :store_location, :only => [:index]  
  
  def get_more_messages
    @messages = get_messages_before params[:before]  
    render :partial => 'message', :collection => @messages
  end
  
  def get_messages_before(first_message_id)
    @conversation.messages.published.find(:all, :include => [:user], :conditions => ["id < ?", first_message_id], :limit => 100, :order => 'id DESC')
  end


  def get_messages_after(cutoff_message_id)
    @conversation.messages.published.find(:all, :include => [:user], :conditions => ["id > ?", cutoff_message_id], :order => 'id ASC')
  end
    
  def index
    @messages = @conversation.messages.published.find(:all, :include => [:user], :limit => 100, :order => 'id DESC')
    current_user.conversation_visit_update(@conversation) if logged_in?
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  def show
    @message = Message.find(params[:id])
    
    respond_to do |format|
      format.html { render :layout => false }
      format.xml  { render :xml => @message }
    end
  end

  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
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
          send_stomp_message @message
          send_stomp_notifications 
          render :nothing => true
        }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @message.errors, :status => :unprocessable_entity }
        format.js { render :nothing => true }
      end
    end
  end

  def upload_attachment
    @message = Message.new(params[:message])    
    @message.user = current_user
    @message.conversation = @conversation
    @message.message = "!!!!!attachment!!!!!!"    


    if params[:message][:attachment].blank?
      render :nothing => true
      return
    end
      
      
      
    # puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:' + @message.attachment_content_type  
      
    if @message.save
      # send a stomp message for everyone else to pick it up
      send_stomp_message @message
      send_stomp_notifications 
      render :nothing => true      
    end
  end

  def report
    message = @conversation.messages.find(params[:id])
    message.report_abuse(current_user)
    render :nothing => true            
  end

  def spawn_conversation
    @message = Message.find(params[:id])

    if Conversation.find_by_parent_message_id_and_user_id(@message.id, current_user.id)
      flash[:error] = "You already spawned a new conversation from this message."
      redirect_to conversation_messsages_path(@conversation)
      return
    end
    
    spawned_conversation = @message.spawn_new_conversation(current_user)

    #create a message in the original conversation notifying about this spawning
    notification_message = Message.new
    notification_message.user = current_user
    notification_message.conversation_id = @conversation.id
    notification_message.message = 
    "\nnew convo: #{HOST}/conversations/#{spawned_conversation.id}/messages 
    spawned by: #{current_user.login} \n
    in response to: #{HOST}/conversations/#{@conversation.id}/messages/#{@message.id} \n
    #{@message.message}"
    
    notification_message.save        
    #and send realtime notification to everyone who's listening
    send_stomp_message(notification_message)
        
    redirect_to conversation_messages_path(spawned_conversation)
  end
  
  
  private

    def find_conversation
      @conversation = Conversation.find( params[:conversation_id] )
    end
    
    def check_write_access
      unless @conversation.writable_by?(current_user)
        flash[:error] = "You are not allowed to add messages to this conversation."
        redirect_to conversation_messages_path(@conversation)
        return
      end
    end
    
    def send_stomp_message(message)
      newmessagescript = render_to_string :partial => 'message', :object => message
      s = Stomp::Client.new
      s.send("CONVERSATION_CHANNEL_" + params[:conversation_id], newmessagescript)
      s.close
    rescue SystemCallError
      logger.error "IO failed: " + $!
      # raise
    end

    def send_stomp_notifications
      s = Stomp::Client.new
      s.send("CONVERSATION_NOTIFY_CHANNEL_" + params[:conversation_id], "1")
      # puts ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CONVERSATION_NOTIFY_CHANNEL_" + params[:conversation_id])
      s.close
    rescue SystemCallError
      logger.error "IO failed: " + $!
      # raise
    end

end
