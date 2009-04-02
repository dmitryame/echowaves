require File.dirname(__FILE__) + '/../test_helper'

class LoginTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions

  context "crossblaim login into echowaves" do
    should "be redirected to his profile if crossblaim is in the convos page" do
      get "/conversations"
      assert_response :success
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_template "users/show.html.erb"
    end
    
    should "be redirected to his profile if crossblaim is in the home page" do
      get "/"
      assert_response :success
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_template "users/show.html.erb"
    end
    
    should "be redirected back to the convo crossblaim was reading before login" do
      get "/conversations/#{conversations(:crossblaim_personal_convo).id}"
      assert_response :success
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_template "conversations/show.html.erb"
    end
    
  end

end