require File.dirname(__FILE__) + '/../test_helper'

class SubscribersControllerTest < ActionController::TestCase

  context "index action" do
    setup do
      @current_user = create_user_and_authenticate
      @convo = Factory.create(:conversation)
      @subscription = Factory.create(:subscription, :conversation => @convo, :user => @current_user)
    end

    context "html request" do
      should "be successful for public convo" do
        get :index, :conversation_id => @convo.id
        assert_response 200
      end

      should "be redirect for private convo" do
        @conv = Factory.create(:conversation, :private => true)
        get :index, :conversation_id => @conv.id
        assert_response 302
        assert_equal flash[:error], "Sorry, this is a private conversation. You can try anoter one"
      end
    end
  end
end
