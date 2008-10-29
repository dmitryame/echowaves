class ConversationsController < ApplicationController

  before_filter :login_required

  auto_complete_for :conversation, :name

  def complete_name
    @conversation = Conversation.find_by_name(params[:id])
    redirect_to conversation_messages_path(@conversation)
  end

  # GET /conversations
  # GET /conversations.xml
  def index    
    @conversations = Conversation.paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @conversations }
    end
  end

  # GET /conversations/1
  # GET /conversations/1.xml
  def show
    @conversation = Conversation.find(params[:id])
    redirect_to(conversation_messages_path(@conversation))  
    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @conversation }
    # end
  end

  # GET /conversations/new
  # GET /conversations/new.xml
  def new
    @conversation = Conversation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @conversation }
    end
  end

  # GET /conversations/1/edit
  # def edit
  #   @conversation = Conversation.find(params[:id])
  # end

  # POST /conversations
  # POST /conversations.xml
  def create
    @conversation = Conversation.new(params[:conversation])
    @conversation.created_by = current_user
    
    respond_to do |format|
      if @conversation.save
        flash[:notice] = 'Conversation was successfully created.'
        format.html { redirect_to(@conversation) }
        format.xml  { render :xml => @conversation, :status => :created, :location => @conversation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @conversation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /conversations/1
  # PUT /conversations/1.xml
  # def update
  #   @conversation = Conversation.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @conversation.update_attributes(params[:conversation])
  #       flash[:notice] = 'Conversation was successfully updated.'
  #       format.html { redirect_to(@conversation) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @conversation.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /conversations/1
  # DELETE /conversations/1.xml
  # def destroy
  #   @conversation = Conversation.find(params[:id])
  #   @conversation.destroy
  #   flash[:notice] = 'Conversation was successfully removed.'
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(conversations_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
