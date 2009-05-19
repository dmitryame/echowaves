# == Schema Info
# Schema version: 20090514235226
#
# Table name: abuse_reports
#
#  id         :integer(4)      not null, primary key
#  message_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#----------------------------------------------------------------------------
class AbuseReport < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :message
  
  validates_presence_of :user_id
  
end
