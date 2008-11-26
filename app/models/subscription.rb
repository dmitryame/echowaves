class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation
  
  validates_presence_of :user_id, :conversation_id

  def new_messages_count
    self.conversation.messages.count :conditions => ["id > ?", self.last_message_id]
  end
  
  def before_create 
    self.last_message_id = 0
  end
  
  def mark_read
    self.last_message_id = self.conversation.messages.last.id
    self.save
  end
  
  
  def activate
    self.mark_read
    self.activated_at = Time.now
    self.save
  end
      
end
