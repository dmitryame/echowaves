# == Schema Info
# Schema version: 20090514235226
#
# Table name: conversation_visits
#
#  id              :integer(4)      not null, primary key
#  conversation_id :integer(4)
#  user_id         :integer(4)
#  visits_count    :integer(4)      default(1)
#  created_at      :datetime
#  updated_at      :datetime
#----------------------------------------------------------------------------
class ConversationVisit < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :conversation
  
  validates_presence_of :conversation_id

  named_scope :recent, :order => "updated_at DESC", :limit => 10
  
end
