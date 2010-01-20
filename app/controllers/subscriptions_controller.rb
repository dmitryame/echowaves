class SubscriptionsController < ApplicationController
  def ssl_required?
    true if USE_SSL
  end

  def create
    @conversation = Conversation.find(params[:conversation_id])
    current_user.follow(@conversation, params[:token])

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @conversation = Conversation.find(params[:conversation_id])
    current_user.unfollow(@conversation)

    respond_to do |format|
      format.js
    end
  end

end
