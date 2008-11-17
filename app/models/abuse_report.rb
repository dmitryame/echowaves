class AbuseReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :message
  
  validates_presence_of :user_id, :message_id
end
