require File.dirname(__FILE__) + '/../test_helper'

class RecentlyVisitedConvosTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions

  context "crossblaim visit some convos" do
    should "see any recently visited convos minus the current convo" do
      post_via_redirect "/user_session", :user_session => { :login => "crossblaim", :password => "secret" }
      assert_response :success
      
      # this is the #1 convo crossblaim visit, the recently visited list should be empty 
      get "/conversations/#{conversations(:crossblaim_personal_convo).id}.js"
      get "/conversations/#{conversations(:crossblaim_personal_convo).id}"
      assert_response :success
      assert_select "div#recently_visited>ul>li", 0
      
      # this is the #2 convo crossblaim visit, the recently visited list
      # should contain the previusly visited convo (crossblaim_personal_convo)
      get "/conversations/#{conversations(:dmitry_personal_convo).id}.js"
      get "/conversations/#{conversations(:dmitry_personal_convo).id}"
      assert_response :success
      assert_select "div#recently_visited>ul>li", 1
      assert_select "div#recently_visited>ul>li", /crossblaim/
      
      # crossblaim visit again his personal convo, the recently visited list
      # should contain the previusly visited convo (dmitry_personal_convo)
      get "/conversations/#{conversations(:crossblaim_personal_convo).id}.js"
      get "/conversations/#{conversations(:crossblaim_personal_convo).id}"
      assert_response :success
      assert_select "div#recently_visited>ul>li", 1
      assert_select "div#recently_visited>ul>li", /dmitry/
      
      # crossblaim visit another page where the recently visited convos list appear,
      # the recently visited list should contain the previusly visited convos (dmitry_personal_convo and crossblaim_personal_convo)
      get "/conversations"
      assert_response :success
      assert_select "div#recently_visited>ul>li", 2
      assert_select "div#recently_visited>ul>li", /dmitry/
      assert_select "div#recently_visited>ul>li", /crossblaim/
    end  
  end

end