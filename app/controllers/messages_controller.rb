class MessagesController < ApplicationController
  before_filter :login_required
  before_filter :find_conversation
    
  def get_messages_after(cutoff_message_id)
    @conversation.messages.find(:all, :include => [:user], :conditions => ["id > ?", cutoff_message_id], :order => 'created_at ASC')
  end
  
  def message_poll
    @messages = get_messages_after params[:after]
    render :partial => 'message', :collection => @messages
  end
  
  # GET /messages
  # GET /messages.xml
  def index
    @messages = @conversation.messages.paginate(:include => [:user], :per_page => 100, :page => params[:page], :order => 'created_at DESC').reverse

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
    @message = Message.new(params[:message])    
    @message.user = current_user
    @message.conversation = @conversation
    
    respond_to do |format|
      if @message.save
        flash[:notice] = 'Message was successfully created.'
        format.html { 
          if request.xhr?
            @messages = get_messages_after params[:after]
            render :partial => 'message', :collection => @messages
          else
            redirect_to(conversation_messages_path(@conversation))
          end
        }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
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

  private

    def find_conversation
      @conversation_id = params[:conversation_id]
      @conversation = Conversation.find(@conversation_id)
    end

end
