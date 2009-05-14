require File.dirname(__FILE__) + '/../test_helper'

class FollowersNotificationTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions

  context "crossblaim creates a new convo" do
    should "notify followers" do
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_response :success
      post_via_redirect "/conversations", :conversation => { :name => 'new crossblaim convo', :description => 'test convo'}
      assert_response :success
      assert_equal "Conversation was successfully created.", flash[:notice]
      @messages = users(:crossblaim).messages.find(:all, :conditions => ['system_message = ?', true], :limit => 2)
      assert_equal 2, @messages.length
      get "/conversations/#{conversations(:dmitry_personal_convo).id}"
      assert_response :success
      assert_match(/this is a personal convo for dmitry/, @response.body)
      # assert_match(/created a new convo\:/, @response.body)
      assert_match(/>new crossblaim convo<\/a>/, @response.body)
      get "/conversations/#{conversations(:akira_personal_convo).id}"
      assert_response :success
      assert_match(/this is a personal convo for akira/, @response.body)
      # assert_match(/created a new convo\:/, @response.body)
      assert_match(/>new crossblaim convo<\/a>/, @response.body)
    end  
  end

end