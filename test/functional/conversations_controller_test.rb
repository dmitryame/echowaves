require 'test_helper'

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
  
  context "makereadonly action" do
    setup do
      @conversation = Factory.create(:conversation)
    end
    
    should "not make the conversation readonly if the current_user is not the owner" do
      @owner = Factory.create(:user, :login => "user1")
      @message1 = Factory.create(:message, :conversation => @conversation, :user => @owner)
      put :makereadonly, :id => @conversation
      assert_equal false, assigns(:conversation).read_only
    end
    
    should "make the conversation readonly if the current_user is the owner" do
      @message1 = Factory.create(:message, :conversation => @conversation, :user => @current_user)      
      put :makereadonly, :id => @conversation
      assert_equal true, assigns(:conversation).read_only
    end  
  end
  
  context "makewritable action" do
    setup do
      @conversation = Factory.create(:conversation)
    end
    
    should "not make the conversation writeable if the current_user is not the owner" do
      @owner = Factory.create(:user, :login => "user1")
      @message1 = Factory.create(:message, :conversation => @conversation, :user => @owner)
      @conversation.update_attributes(:read_only => true)
      put :makewriteable, :id => @conversation
      assert_equal true, assigns(:conversation).read_only
    end
    
    should "make the conversation writeable if the current_user is the owner" do
      @message1 = Factory.create(:message, :conversation => @conversation, :user => @current_user)      
      @conversation.update_attributes(:read_only => true)
      put :makewriteable, :id => @conversation
      assert_equal false, assigns(:conversation).read_only
    end  
  end
  
end
