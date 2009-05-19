# == Schema Info
# Schema version: 20090514235226
#
# Table name: oauth_tokens
#
#  id                    :integer(4)      not null, primary key
#  client_application_id :integer(4)
#  user_id               :integer(4)
#  secret                :string(50)
#  token                 :string(50)
#  type                  :string(20)
#  authorized_at         :datetime
#  created_at            :datetime
#  invalidated_at        :datetime
#  updated_at            :datetime
#----------------------------------------------------------------------------
class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :user
  validates_uniqueness_of :token
  validates_presence_of :client_application, :token, :secret
  before_validation_on_create :generate_keys
  
  def invalidated?
    invalidated_at != nil
  end
  
  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end
  
  def authorized?
    authorized_at != nil && !invalidated?
  end
  
  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end
    
protected
  
  def generate_keys
    @oauth_token = client_application.oauth_server.generate_credentials
    self.token = @oauth_token[0]
    self.secret = @oauth_token[1]
  end
end
