require 'stomp'

class MessagesController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :get_more_messages ]
  before_filter :find_conversation, :except => :send_data
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

    # add a new conversation_visit to the history
    @conversation.add_visit(current_user) if logged_in?

    if current_user
      # make sure the conversation we were last viwing does not have updates
      last_viewed_subscription = Subscription.find_by_user_id(current_user.id, :order => 'activated_at DESC')
      last_viewed_subscription.mark_read if(last_viewed_subscription)

      # adjust current conversation last message
      current_subscription = Subscription.find_by_user_id_and_conversation_id(current_user.id, @conversation.id)
      current_subscription.activate if(current_subscription != nil)

    end#if current_user

    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  
  # GET /messages/1
  # GET /messages/1.xml
  def show
    @message = Message.find(params[:id])
    
    respond_to do |format|
      format.html { render :layout => false }
      format.xml  { render :xml => @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.xml
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message }
    end
  end

  # # GET /messages/1/edit
  # def edit
  #   @message = Message.find(params[:id])
  # end

  # POST /messages
  # POST /messages.xml
  def create
    raise "error" unless @conversation.writable_by?(current_user)
    @message = Message.new(params[:message])
    @message.user = current_user
    @message.conversation = @conversation
    
    respond_to do |format|
      if @message.save
        # flash[:notice] = 'Message was successfully created.'
    
        format.html {
          if request.xhr?
            # send a stomp message for everyone else to pick it up
            send_stomp_message @message
            send_stomp_notifications 
            
            render :nothing => true
          else
            redirect_to(conversation_messages_path(@conversation))
          end
        }
        format.xml { render :xml => @message, :status => :created, :location => @message }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @message.errors, :status => :unprocessable_entity }
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

  # # PUT /messages/1
  # # PUT /messages/1.xml
  # def update
  #   @message = Message.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @message.update_attributes(params[:message])
  #       flash[:notice] = 'Message was successfully updated.'
  #       format.html { redirect_to(@message) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /messages/1
  # # DELETE /messages/1.xml
  # def destroy
  #   @message = Message.find(params[:id])
  #   @message.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(messages_url) }
  #     format.xml  { head :ok }
  #   end
  # end

  def report
    message = Message.find(params[:id])

    #if was already reported by the current_user, don't do anything
    if(AbuseReport.find_by_user_id_and_message_id( current_user.id, message.id))
      render :nothing => true
      return
    end
    
    abuseReport = AbuseReport.new
    abuseReport.message = message
    abuseReport.user = current_user
    abuseReport.save
    
    # if a conversation owner reported an abuse, or 3 other non owners -- deactivate the message
    if (current_user == message.conversation.owner || message.abuse_reports.size > 3)
      message.abuse_report = abuseReport # the final abuse report that makes message deactivated
      message.save
      # perhaps this line is really important in publicly installed site like http://echowaves.com. could be parameterized for local installs
      system "chmod -R 000 ./public/attachments/#{message.id}"
    end
    render :nothing => true            
  end

  def spawn_conversation
    @message = Message.find(params[:id])
    
    spawned_conversations = Conversation.find_all_by_parent_message_id(@message.id)
    # there got to be a better way, for now just walk all responses and ask for the owner
    spawned_conversations.each do|convo| 
      if(convo.owner == current_user)
        flash[:error] = "You already spawned from this message"
        redirect_to conversation_messages_path(@conversation)
        return
      end
    end
    
    spawned_conversation = @message.spawn_new_conversation(current_user)

    #create a message in the original conversation notifying about this spawning
    notification_message = Message.new
    notification_message.user = current_user
    notification_message.conversation_id = @conversation_id
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
      @conversation_id = params[:conversation_id]
      @conversation = Conversation.find(@conversation_id)
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
