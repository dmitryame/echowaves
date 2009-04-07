require File.dirname(__FILE__) + '/../test_helper'

class SingleAccessTokenTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions

  context "creating a convo" do
    should "don't create a convo" do
      post_via_redirect "/conversations", :conversation => { :name => 'new crossblaim convo', :description => 'test convo'}
      assert_template "user_sessions/new.html.erb"
    end
    
    should "create a convo" do
      post_via_redirect "/conversations", :conversation => { :name => 'new crossblaim convo', :description => 'test convo'}, :user_credentials => users(:crossblaim).single_access_token
      assert_template "conversations/show.html.erb"
      assert_response :success
      assert_equal "Conversation was successfully created.", flash[:notice]
      assert_equal users(:crossblaim), Conversation.find_by_name("new crossblaim convo").user
    end  
  end
  


  context "posting a message" do
    
    should "don't post a message" do
      post_via_redirect "/conversations/#{conversations(:dmitry_personal_convo).id}/messages", :message => { :message => 'no token, no message' }
      assert_template "user_sessions/new.html.erb"
    end
    
    should "post a message" do
      %w(crossblaim dmitry akira).each do |u|
        post_via_redirect "/conversations/#{conversations(:dmitry_personal_convo).id}/messages", :message => { :message => 'no token, no message' }, :user_credentials => users(u).single_access_token
        assert_template "conversations/show.html.erb"
        assert_response :success
        assert_equal 'no token, no message', Message.last.message
        assert_equal users(u), Message.last.user
      end
    end
    
  end

end