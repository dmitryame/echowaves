class HomeController < ApplicationController
  # just a homepage
  def index
    @conversation = begin Conversation.find(HOME_CONVERSATION); rescue; end
    @messages = begin @conversation.messages.published.find(:all, :include => [:user], :limit => 30, :order => 'id DESC'); rescue; end
  end
  
  def terms
  end

end
