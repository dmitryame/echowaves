# == Schema Info
# Schema version: 20090514235226
#
# Table name: subscriptions
#
#  id              :integer(4)      not null, primary key
#  conversation_id :integer(4)
#  last_message_id :integer(4)      default(0)
#  user_id         :integer(4)
#  activated_at    :datetime
#  created_at      :datetime
#  updated_at      :datetime
#----------------------------------------------------------------------------
class Subscription < ActiveRecord::Base
  
  belongs_to :user, :counter_cache => true
  belongs_to :conversation, :counter_cache => true
  
  validates_presence_of :user_id, :conversation_id
  
  def new_messages_count
    if self.conversation_id == user.personal_conversation_id
      self.conversation.messages.count :conditions => ["id > ?", self.last_message_id]
    else
      self.conversation.messages.count :conditions => ["id > ? and system_message is FALSE", self.last_message_id]
    end
  end
  
  def mark_read
    self.update_attributes(:last_message_id => self.conversation.messages.last.id) unless self.conversation.messages.blank?
  end
  
  def activate!
    self.mark_read
    self.activated_at = Time.now
    self.save
  end
  
end
