require File.dirname(__FILE__) + '/../test_helper'

class FollowersNotificationTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions

  context "crossblaim creates a new convo" do
    should "notify followers" do
      # login
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_response :success
      # create a new convo
      post_via_redirect "/conversations", :conversation => { :name => 'new crossblaim convo', :description => 'test convo'}
      # TODO: defered 
      # assert_response :success
      # TODO: defered 
      # assert_equal "Conversation was successfully created.", flash[:notice]
      @messages = users(:crossblaim).messages.find(:all, :conditions => ['system_message = ?', true], :limit => 2)
      # assert_equal 2, @messages.length
      # the actual messages for this convo are requested in js after the page loads
      get "/conversations/#{conversations(:dmitry_personal_convo).id}/messages/system_messages.json"    
      assert_response :success
      # TODO: defered 
      # assert_match(/created a new convo\:/, @response.body)
      # TODO: defered 
      # assert_match(/>new crossblaim convo<\/a>/, @response.body)
      # the actual messages for this convo are requested in js after the page loads
      get "/conversations/#{conversations(:akira_personal_convo).id}/messages/system_messages.json"
      assert_response :success
      # TODO: defered 
      # assert_match(/created a new convo\:/, @response.body)
      # TODO: defered 
      # assert_match(/>new crossblaim convo<\/a>/, @response.body)
    end  
  end

end