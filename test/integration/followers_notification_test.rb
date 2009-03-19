require File.dirname(__FILE__) + '/../test_helper'

class FollowersNotificationTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions

  context "crossblaim creates a new convo" do
    setup do
      @crossblaim = users(:crossblaim)
      @dmitry = users(:dmitry)
      @akira = users(:akira)
      @user = User.new(:login => "user",
                          :password => "secret",
                          :password_confirmation => "secret",
                          :email => "test@test.com",
                          :email_confirmation => "test@test.com")
      @user.login = 'user'
      @user.save
      @user.activate!
      @crossblaim.activate!
    end
    
    should "notify followers" do
      assert @user.valid?
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_response :success
      #post_via_redirect "/conversations", :conversation => { :name => 'new crossblaim convo', :description => 'test convo'}
      #assert_response :success
      #assert Conversation.find_by_name('new crossblaim convo')
    end
  
  end
  
 # test "" test_login_and_browse_site
 #   # login via https
 #   https!
 #   get "/login"
 #   assert_response :success
 #
 #   post_via_redirect "/login", :username => users(:avs).username, :password => users(:avs).password
 #   assert_equal '/welcome', path
 #   assert_equal 'Welcome avs!', flash[:notice]
 #
 #   https!(false)
 #   get "/posts/all"
 #   assert_response :success
 #   assert assigns(:products)
 # end
end