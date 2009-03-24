class HomeController < ApplicationController
  
  # just a homepage
  def index
    @users = User.active.find(:all, :order => 'created_at DESC', :limit => 56)
    @recent_convos = Conversation.published.non_private.not_personal.find(:all, :order => 'created_at DESC', :limit => 10)
    @popular_convos = Conversation.most_popular
    @total_convos = Conversation.published.count
    @total_messages = Message.published.count
    @total_users = User.active.count
  end
  
  def terms
  end
  
end
