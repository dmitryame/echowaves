# == Schema Info
# Schema version: 20090514235226
#
# Table name: invites
#
#  id              :integer(4)      not null, primary key
#  conversation_id :integer(4)
#  requestor_id    :integer(4)
#  user_id         :integer(4)
#  token           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#----------------------------------------------------------------------------
class Invite < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :conversation
  belongs_to :requestor, 
    :class_name  => "User",
    :foreign_key => "requestor_id"

  validates_presence_of :requestor_id
  # validates_presence_of :user_id
  validates_presence_of :conversation_id
  
  def reset_token!
    self.token = nil
    self.save
  end
  
end
