require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  # fixtures :users

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_complete_name_action
    user = Factory.create( :user )
    User.expects( :find_by_name ).with( user.name ).returns( user )
    get :complete_name, :id => user.name 
    assert assigns( :user )
    assert_redirected_to user_path( user ) 
  end
  
  def test_should_return_users_on_index
    get :index
    assert assigns( :users )
    assert_response :success
    assert_template "users/index"
  end 

  def test_should_find_and_return_user_on_show
    user = Factory.create( :user )
    get :show, :id => user.id
    assert assigns( :user )
    assert_response :success
    assert_template "users/show"
  end

  def test_should_return_new_blank_user_on_new 
    get :new
    assert assigns( :user )
    assert_response :success
    assert_template "users/new"
  end

  def test_should_return_current_user_for_edit_action
    user = Factory.create( :user )
    @request.session[:user_id] = user.id
    get :edit
    assert assigns( :user )
    assert_equal assigns( :user ), user
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end
