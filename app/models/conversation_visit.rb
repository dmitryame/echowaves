class ConversationVisit < ActiveRecord::Base
  belongs_to :user
  belongs_to :conversation
  
  validates_presence_of :user_id, :conversation_id
end
