require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @controller = HomeController.new
    @conversation = Factory.create( :conversation, :id => HOME_CONVERSATION )
  end

  context "#index action" do
    should "be successful and render the index template " do
      get :index
      assert assigns( :conversation )
      assert assigns( :messages )
      assert_response :success
      assert_template "home/index"
    end

    should "find the HOME_CONVERSATION and its messages" do
      Conversation.expects( :find ).with( HOME_CONVERSATION ).returns( @conversation )
      @conversation.expects( :messages ).returns( [ Factory.create( :message ) ] )
      get :index
    end
  end # context #index action

  context "#terms action" do
    should "render the terms template and be successful" do
      get :terms
      assert_response :success
      assert_template "home/terms"
    end
  end

end
