class HomeController < ApplicationController
  
  # just a homepage
  def index
    @users = User.find(:all, :order => 'created_at DESC', :limit => 50, :conditions => "activated_at is not null")
    @recent_convos = Conversation.find(:all, :order => 'created_at DESC', :limit => 10, :conditions => "abuse_report_id is null and personal_conversation = 0")
    @popular_convos = ConversationVisit.find(:all, :group => :conversation_id, :order => "visits_count DESC", :limit => 10).map { |convo_visit| convo_visit.conversation }    

    @total_convos = Conversation.published.count
    @total_messages = Message.published.count
    @total_users = User.active.count
  end
  
  def terms
  end
  
end
