class AbuseReport < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :message
  belongs_to :conversation
  
  validates_presence_of :user_id
  
end
