require File.dirname(__FILE__) + '/../test_helper'

class SubscribersControllerTest < ActionController::TestCase

  context "index action" do
    setup do
      @current_user = create_user_and_authenticate
      @convo = Factory.create(:conversation)
      @subscription = Factory.create(:subscription, :conversation => @convo, :user => @current_user)
    end

    context "html request" do
      should "be success" do
        get :index, :conversation_id => @convo.id
        assert_response 200
      end
    end
  end
end
