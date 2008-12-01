require File.dirname(__FILE__) + '/../test_helper'

class ConversationsControllerTest < ActionController::TestCase
  def setup
    #authenticate
    @current_user = create_user_and_authenticate
    @conversation = Factory(:conversation)
    @controller = ConversationsController.new
  end
   
  should_be_restful do |resource| 
    resource.create.params = { :name => "random conversation", :description => "random conversations description"}
    resource.update.params = { :name => "random conversation changed", :description => "changed random conversations description"}
    resource.actions    = [
      :index,
      # :show, 
      :new, 
      # :edit, 
      # :update, 
      :create#, 
      # :destroy
      ]    
  end

  context "readwrite_status action" do
    setup do
      @owner = Factory.create(:user, :login => 'user1')
      @conversation = Factory.create(:conversation, :user => @current_user)
    end

    context "convo belongs to other user " do
      setup do
        @other_conversation = Factory.create(:conversation, :user => @owner)
      end

      should "only allow changes if the current_user is the conversation owner" do
        # try to change to writeable
        @other_conversation.update_attribute(:read_only, true)
        put :readwrite_status, :id => @other_conversation, :mode => 'rw'
        assert_equal true, assigns(:conversation).read_only

        # try to change to readonly
        @other_conversation.update_attribute(:read_only, false)
        put :readwrite_status, :id => @other_conversation
        assert_equal false, assigns(:conversation).read_only
      end
    end

    context "convo belongs to current_user" do
      should "make readonly with no mode param" do
        put :readwrite_status, :id => @conversation
        assert_equal true, assigns(:conversation).read_only
      end

      should "make writeable with rw mode param" do
        put :readwrite_status, :id => @conversation, :mode => 'rw'
        assert_equal false, assigns(:conversation).read_only 
      end
    end
  end

end
