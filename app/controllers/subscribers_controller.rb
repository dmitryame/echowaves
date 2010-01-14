class SubscribersController < ApplicationController
  def ssl_required?
    true if USE_SSL
  end

  def index
    @conversation = Conversation.find(params[:conversation_id])

    respond_to do |format|
      if @conversation.readable_by?(current_user) || @conversation.public?
        @subscribers = @conversation.users
        format.html
        format.xml { render :xml => { :subscribers => @subscribers } }
      else
        flash[:error] = "Sorry, this is a private conversation. You can try anoter one"
        format.html { redirect_to conversations_path }
      end
    end
  end
end
