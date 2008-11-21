class HomeController < ApplicationController
  # just a homepage
  def index
    @conversation = Conversation.find(HOME_CONVERSATION)
    @messages = @conversation.messages.published.find(:all, :include => [:user], :limit => 30, :order => 'id DESC')
  end
  
  def terms
  end

end
