class SubscribersController < ApplicationController
  def ssl_required?
    true if USE_SSL
  end

  def index
    @conversation = Conversation.find(params[:conversation_id])

    respond_to do |format|
      if @conversation.public? || @conversation.readable_by?(current_user)
        @subscribers = @conversation.users
        format.html
        format.xml { render :xml => { :subscribers => @subscribers } }
      else
        flash[:error] = "Sorry, this is a private conversation. You can try another one"
        format.html { redirect_to conversations_path }
      end
    end
  end

  def create
    @conversation = Conversation.find(params[:conversation_id])
    current_user.follow(@conversation, params[:token])

    respond_to do |format|
      format.js
    end
  end
end
