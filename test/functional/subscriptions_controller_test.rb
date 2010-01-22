require File.dirname(__FILE__) + '/../test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  def setup
    @current_user = create_user_and_authenticate
    @convo = Factory.create(:conversation)
    @subscription = Factory.create(:subscription, :conversation => @convo, :user => @current_user)
  end

  context "create action" do
    should "be success" do
      xhr :post, :create, :conversation_id => @convo.id
      assert_response 200
    end
  end
end
