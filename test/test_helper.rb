ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
%w(test_help mocha factory_girl).each { |lib| require lib }
require File.expand_path(File.dirname(__FILE__) + "/factories")

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all

  #this method creates a admin/admin account, sets all the models with the relationships to give full authorization to the whole site, and authenticates
  def create_user_and_authenticate
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @user = Factory(:user, :login => "admin", :email => "qwe@mail.com", :password => "password", :password_confirmation => "password")
    
    #activate the user so it can be logged in
    @user.activate!
    
    @request.env['HTTP_AUTHORIZATION'] = 
    ActionController::HttpAuthentication::Basic.encode_credentials(
    "admin", 
    "password" 
    )
    @user
  end


end
