require File.dirname(__FILE__) + '/../test_helper'

class PrivateConvosTest < ActionController::IntegrationTest
  fixtures :users, :conversations, :messages
  
  #---------------------------------------------------------------------------- 
  context "browsing some private convos" do
    
    should "be able to read the convo if I'm the owner" do
      login_as('crossblaim')
      assert_response :success      
      goto_convo(:crossblaim_test_private_convo)
      assert_response :success
    end
    
    should "be able to read the convo if I'm not the owner but I follow the convo" do
      login_as('akira')
      assert_response :success
      goto_convo(:crossblaim_test_private_convo)
      assert_response :success
    end
    
    should "not be able to read the convo if I'm not the owner and I don't follow the convo" do
      login_as('dmitry')
      assert_response :success      
      goto_convo(:crossblaim_test_private_convo)
      assert_response :redirect
    end  

  end
  
  # API
  #----------------------------------------------------------------------------
  context "browsing some private convos (API)" do
    
    should "be able to read the convo if I'm the owner" do
      login_as('crossblaim')
      assert_response :success      
      goto_convo_api(:crossblaim_test_private_convo, 'json')
      assert_response :success
      goto_convo_api(:crossblaim_test_private_convo, 'xml')
      assert_response :success
    end
    
    should "be able to read the convo if I'm not the owner but I follow the convo" do
      login_as('akira')
      assert_response :success
      goto_convo_api(:crossblaim_test_private_convo, 'json')
      assert_response :success
      goto_convo_api(:crossblaim_test_private_convo, 'xml')
      assert_response :success
    end
    
    should "not be able to read the convo if I'm not the owner and I don't follow the convo" do
      login_as('dmitry')
      assert_response :success      
      goto_convo_api(:crossblaim_test_private_convo, 'json')
      assert_response :redirect
      goto_convo_api(:crossblaim_test_private_convo, 'xml')
      assert_response :redirect
    end  

  end  
end