class Invite < ActiveRecord::Base
  
  belongs_to :requestor, 
    :class_name  => "User",
    :foreign_key => "requestor_id"
    
  belongs_to :user
  belongs_to :conversation  

  validates_presence_of :requestor_id
  validates_presence_of :user_id
  validates_presence_of :conversation_id
  
end
