require File.dirname(__FILE__) + '/../test_helper'

class SignupTest < ActionController::IntegrationTest

  context "a new user" do
    should "activate the account and login" do
      get "/users/new"
      assert_response :success
      assert_difference('User.count') do
        post_via_redirect "/users", :user => {  :login => "user",
                                                :email => "user@fake.com",
                                                :email_confirmation => "user@fake.com",
                                                :name => "Fake Name",
                                                :password => "secret",
                                                :password_confirmation => "secret",
                                                :time_zone => "UTC" }
      end
      assert_response :success
      @user = User.find_by_name("Fake Name") # the new user should be in the database
      assert @user
      assert !@user.active?                  # and should not be active yet
      
      get "/user_session/new"
      assert_response :success
      post_via_redirect "user_session", :user_session => { :login => "user", :password => "secret" }
      assert_equal "Couldn't log you in as user", flash[:error] # user can't login until the account is activated
      
      get "/activate/#{@user.perishable_token}"
      assert_redirected_to "/login"
      assert_equal "Signup complete! Please login to continue.", flash[:notice] # user should be activated now
      assert @user.reload.active?
      
      post_via_redirect "user_session", :user_session => { :login => "user", :password => "secret" }
      assert_response :success
      assert_equal "Logged in successfully", flash[:notice] # the user can login at last
    end  
  end

end