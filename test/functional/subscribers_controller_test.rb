require File.dirname(__FILE__) + '/../test_helper'

class SubscribersControllerTest < ActionController::TestCase

  def setup
    @current_user = create_user_and_authenticate
    @convo = Factory.create(:conversation)
    @subscription = Factory.create(:subscription, :conversation => @convo, :user => @current_user)
  end

  context "index action" do
    context "html request" do
      should "be successful for public convo" do
        get :index, :conversation_id => @convo.id
        assert_response 200
      end

      should "be redirect for private convo" do
        conv = Factory.create(:conversation, :private => true)
        get :index, :conversation_id => conv.id
        assert_response 302
        assert_equal flash[:error], "Sorry, this is a private conversation. You can try another one"
      end
    end
  end

  context "destroy action" do
    conv = Factory.create(:conversation, :private => true)
    subscriber = Factory.create(:user)
    conv.users << subscriber

    should "be success" do
      xhr :delete, :destroy, { :conversation_id => conv.id, :id => subscriber.id }
      assert_response 200
    end
  end

end
