require 'stomp'

class MessagesController < ApplicationController
  before_filter :login_required, :except => [:index, :get_more_messages ]
  before_filter :find_conversation, :except => :send_data
    
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
    
  # GET /messages
  # GET /messages.xml
  def index
    @messages = @conversation.messages.published.find(:all, :include => [:user], :limit => 100, :order => 'id DESC')

    # add a new conversation_visit to the history
    conversation_visit = ConversationVisit.new
    conversation_visit.user = current_user if current_user
    conversation_visit.conversation = @conversation
    conversation_visit.save

    if current_user
      # make sure the conversation we were last viwing does not have updates
      last_viewed_subscription = Subscription.find(:first, :conditions => ["user_id = ? ", current_user.id], :order => 'activated_at DESC')
      if(last_viewed_subscription)
        last_viewed_subscription.last_message_id = last_viewed_subscription.conversation.messages.last.id
        last_viewed_subscription.save
      end

      # adjust current conversation last message
      current_subscription = Subscription.find(:first, :conditions => ["user_id = ? and conversation_id = ?", current_user.id, @conversation.id])
      if(current_subscription != nil)
        current_subscription.last_message_id = @messages.last.id if @messages.size > 0
        current_subscription.activated_at = Time.now
        current_subscription.save
      end  
    end#if current_user

    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  
  # # GET /messages/1
  # # GET /messages/1.xml
  # def show
  #   @message = Message.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @message }
  #   end
  # end

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
      message.deactivated_at = Time.now 
      message.save
      # perhaps this line is really important in publicly installed site like http://echowaves.com. could be parameterized for local installs
      system "chmod -R 000 ./public/attachments/#{message.id}"
    end
    render :nothing => true            
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
