require File.dirname(__FILE__) + '/../test_helper'
require 'user_sessions_controller'

# Re-raise errors caught by the controller.
class UserSessionsController; def rescue_action(e) raise e end; end

class UserSessionsControllerTest < ActionController::TestCase
  
  def setup
    # @current_user = create_user_and_authenticate
    @user = Factory(:user, :login => "admin", :name => "Dmitry Amelchenko", :email => "qwe@mail.com", :password => "password", :password_confirmation => "password")
    @user.activate!
  end

  should "get new" do
    get :new
    assert_response :success
  end
  
  should "create user session" do
    post :create, :user_session => { :login => "admin", :password => "password" }
    assert user_session = UserSession.find
    assert_equal @user, user_session.user
    assert_redirected_to user_path(user_session.user)
  end
  
  should "destroy user session" do
    delete :destroy
    assert_nil UserSession.find
    assert_redirected_to new_user_session_path
  end

  def test_should_fail_login_and_not_redirect
    post :create, :user_session => { :login => "admin", :password => "bad_password" }
    assert_nil UserSession.find
    assert_response :success
  end
  
  def test_should_login_with_cookie
    set_cookie_for(@user)
    get :new
    assert @controller.send(:logged_in?)
  end
end
