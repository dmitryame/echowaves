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
class RequestToken < OauthToken
  def authorize!(user)
    return false if authorized?
    self.user = user
    self.authorized_at = Time.now
    self.save
  end
  
  def exchange!
    return false unless authorized?
    RequestToken.transaction do
      access_token = AccessToken.create(:user => user, :client_application => client_application)
      invalidate!
      access_token
    end
  end
end