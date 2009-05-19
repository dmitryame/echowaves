# == Schema Info
# Schema version: 20090514235226
#
# Table name: client_applications
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  callback_url :string(255)
#  key          :string(50)
#  name         :string(255)
#  secret       :string(50)
#  support_url  :string(255)
#  url          :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#----------------------------------------------------------------------------
require 'oauth'
class ClientApplication < ActiveRecord::Base
  belongs_to :user
  has_many :tokens, :class_name => "OauthToken"
  validates_presence_of :name, :url, :key, :secret
  validates_uniqueness_of :key
  before_validation_on_create :generate_keys
  
  def self.find_token(token_key)
    token = OauthToken.find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      logger.info "Loaded #{token.token} which was authorized by (user_id=#{token.user_id}) on the #{token.authorized_at}"
      token
    else
      nil
    end
  end
  
  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      logger.info "Signature Base String: #{signature.signature_base_string}"
      logger.info "Consumer: #{signature.send :consumer_key}"
      logger.info "Token: #{signature.send :token}"
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      logger.info "Signature verification returned: #{value.to_s}"
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      logger.info "ERROR"+e.to_s
      false
    end
  end
  
  def oauth_server
    @oauth_server ||= OAuth::Server.new(HOST)
  end
  
  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end
    
  def create_request_token
    RequestToken.create :client_application => self
  end
  
protected
  
  def generate_keys
    @oauth_client = oauth_server.generate_consumer_credentials
    self.key = @oauth_client.key
    self.secret = @oauth_client.secret
  end
end
