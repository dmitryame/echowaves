class HomeController < ApplicationController
  
  # just a homepage
  def index
    @users = User.active.find(:all, :order => 'created_at DESC', :limit => 28)
    @recent_convos = Conversation.non_private.not_personal.find(:all, :order => 'created_at DESC', :limit => 10)
    @popular_convos = Conversation.most_popular
    @total_convos = Conversation.count
    @total_messages = Message.published.count
    @total_users = User.active.count
  end
  
  def terms
  end
  
end
