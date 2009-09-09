class HomeController < ApplicationController
  
  # just a homepage
  def index
    @users = User.active.find(:all, :order => 'created_at DESC', :limit => 24)
    @recent_convos = Conversation.non_private.find(:all, :order => 'created_at DESC', :limit => 5)
    @popular_convos = Conversation.non_private.most_popular
    @total_convos = Conversation.count
    @total_messages = Message.published.count
    @total_users = User.active.count
  end
  
  def terms
  end
  
end
