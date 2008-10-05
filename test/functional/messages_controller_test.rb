require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  def setup
    #authenticate
    create_user_and_authenticate
    @conversation = Factory(:conversation)
    @message = Factory(:message, :message => "some random message", :conversation => @conversation, :user => @user)
    @controller = MessagesController.new
  end

  should_be_restful do |resource| 
    resource.parent     = [ :conversation ]        
    resource.create.params = { :message => "random message"}
    resource.update.params = { :message => "Changed message" }
    resource.actions    = [
      :index#,
      # :show, 
      # :new, 
      # :edit, 
      # :update, 
      # :create, 
      # :destroy
      ]    
    
  end        

end
