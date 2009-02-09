require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase
  
  setup do
    @quentin = Factory(:user, 
                      :login => "quentin", 
                      :email => "quentin@example.com", 
                      :password => "monkey",
                      :password_confirmation => "monkey",
                      :created_at => 5.days.ago.to_s, 
                      :activated_at => 3.days.ago.to_s,
                      :remember_token_expires_at => 1.days.from_now.to_s,
                      :remember_token => "77de68daecd823babbb58edb1c8e14d7106e83bb")
    @quentin.activate!
    
    @aaron = Factory(:user, 
                      :login => "aaron", 
                      :email => "aaron@example.com", 
                      :password => "monkey",
                      :password_confirmation => "monkey",
                      :created_at => 1.days.ago.to_s, 
                      :activated_at => 3.days.ago.to_s)                      
    @aaron.activate!
    
    @old_password_holder = Factory(:user, 
                      :login => "old_password_holder", 
                      :email => "salty_dog@example.com", 
                      :password => "monkey",
                      :password_confirmation => "monkey",
                      :created_at => 1.days.ago.to_s, 
                      :activated_at => 3.days.ago.to_s)
    @old_password_holder.activate!    
    
  end


  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'monkey'
    assert session[:user_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  def test_should_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :login => 'quentin', :password => 'monkey', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :login => 'quentin', :password => 'monkey', :remember_me => "0"
    puts @response.cookies["auth_token"]
    assert @response.cookies["auth_token"].blank?
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end

  def test_should_login_with_cookie
    users(:quentin).remember_me
    
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
