class ConversationVisit < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :conversation
  
  validates_presence_of :conversation_id

  named_scope :recent, :order => "updated_at DESC", :limit => 10
  
end
