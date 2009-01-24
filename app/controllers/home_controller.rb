class HomeController < ApplicationController
  
  # just a homepage
  def index
    @users = User.find(:all, :order => 'created_at DESC', :limit => 56, :conditions => "activated_at is not null")
    @recent_convos = Conversation.find(:all, :order => 'created_at DESC', :limit => 10, :conditions => "abuse_report_id is null and personal_conversation = 0")

    @popular_convos = Conversation.most_popular

    @total_convos = Conversation.published.count
    @total_messages = Message.published.count
    @total_users = User.active.count
  end
  
  def terms
  end
  
end
