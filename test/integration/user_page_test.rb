require File.dirname(__FILE__) + '/../test_helper'

class UserPageTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions
  
  context "user profile" do
    
    setup do
      @crossblaim = users(:crossblaim)
      get "/users/#{@crossblaim.id}"
      assert_response :success
    end
    
    should "show user information" do
      assert_select 'div.bbox' do
        assert_select 'div.avatar'
        assert_select 'span.username', /crossblaim/
        assert_select 'span.userinfo', "since: #{@crossblaim.date} | #{@crossblaim.conversations.size.to_s}&nbsp;Convos | #{@crossblaim.messages.size.to_s}&nbsp;Messages | #{@crossblaim.following.size.to_s}&nbsp;Following | #{@crossblaim.followers.size.to_s}&nbsp;Followers"
      end
    end
    
    should "show all convos created by the user" do
      assert_select 'ul.list' do
        assert_select 'li', /crossblaim test public convo/
        assert_select 'li', /crossblaim test private convo/
      end
    end
    
  end

end