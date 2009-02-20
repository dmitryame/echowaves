require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @controller = HomeController.new
    @conversation = Factory.create( :conversation, :id => HOME_CONVERSATION )
  end

  context "#index action" do
    should "be successful and render the index template " do
      user = Factory.create( :user )
      followers = [ Factory.create( :user ), Factory.create(:user) ]
      convo = Factory.create( :conversation )
      user.stubs( :personal_conversation ).returns( convo )
      convo.stubs( :users ).returns( followers )
      User.expects( :find ).returns( [user] )
      
      get :index
      assert_response :success
      assert_template "home/index"
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
