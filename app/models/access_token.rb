# == Schema Info
# Schema version: 20090825132952
#
# Table name: oauth_tokens
#
#  id                    :integer(4)      not null, primary key
#  client_application_id :integer(4)
#  user_id               :integer(4)
#  callback_url          :string(255)
#  secret                :string(40)
#  token                 :string(20)
#  type                  :string(20)
#  verifier              :string(20)
#  authorized_at         :datetime
#  created_at            :datetime
#  invalidated_at        :datetime
#  updated_at            :datetime

class AccessToken<OauthToken
  
  validates_presence_of :user
  before_create :set_authorized_at
  
protected 
  
  def set_authorized_at
    self.authorized_at = Time.now
  end
  
end