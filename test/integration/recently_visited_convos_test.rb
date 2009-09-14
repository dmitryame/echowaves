require File.dirname(__FILE__) + '/../test_helper'

class RecentlyVisitedConvosTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :subscriptions

  context "crossblaim visit some convos" do
    should "see any recently visited convos minus the current convo" do
      login_as('crossblaim')
      assert_response :success
      
      # this is the #1 convo crossblaim visit, the recently visited list should be empty 
      goto_convo(:crossblaim_convo)
      assert_response :success
      assert_select "div#recently_visited>div>ul>li", 0
      
      # this is the #2 convo crossblaim visit, the recently visited list
      # should contain the previusly visited convo (crossblaim_personal_convo)
      goto_convo(:dmitry_convo)
      assert_response :success
      assert_select "div#recently_visited>div>ul>li", 1
      assert_select "div#recently_visited>div>ul>li", /crossblaim/
      
      # crossblaim visit again his personal convo, the recently visited list
      # should contain the previusly visited convo (dmitry_personal_convo)
      goto_convo(:crossblaim_convo)
      assert_response :success
      assert_select "div#recently_visited>div>ul>li", 1
      assert_select "div#recently_visited>div>ul>li", /dmitry/
      
      # crossblaim visit another page where the recently visited convos list appear,
      # the recently visited list should contain the previusly visited convos (dmitry_personal_convo and crossblaim_personal_convo)
      get "/conversations"
      assert_response :success
      assert_select "div#recently_visited>div>ul>li", 2
      assert_select "div#recently_visited>div>ul>li", /dmitry/
      assert_select "div#recently_visited>div>ul>li", /crossblaim/
    end  
  end

end