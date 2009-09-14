require File.dirname(__FILE__) + '/../test_helper'

class FollowersNotificationTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions
  setup do
    User.any_instance.stubs(:invite).returns(true)
    Object.redefine_const(:USE_WORKLING, false)
  end
  context "crossblaim creates a new convo" do
    should "notify followers" do
      # login
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_response :success
      # create a new convo
      # post_via_redirect "/conversations", :conversation => { :name => 'new crossblaim convo' }
      # assert_response :success
      # assert_equal "Conversation was successfully created.", flash[:notice]
      # the actual messages for this convo are requested in js after the page loads
    end  
  end

end
