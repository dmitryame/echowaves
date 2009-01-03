class Subscription < ActiveRecord::Base
  
  belongs_to :user, :counter_cache => true
  belongs_to :conversation, :counter_cache => true
  
  validates_presence_of :user_id, :conversation_id

  def new_messages_count
    self.conversation.messages.count :conditions => ["id > ? and system_message is FALSE", self.last_message_id]
  end
  
  def mark_read
    self.update_attributes(:last_message_id => self.conversation.messages.last.id) unless self.conversation.messages.blank?
  end
  
  def activate
    self.mark_read
    self.activated_at = Time.now
    self.save
  end
  
end
