require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  def setup
    #authenticate
    create_user_and_authenticate
    @conversation = Factory(:conversation, :created_by => @user)
    @message = Factory(:message, :message => "some random message", :conversation => @conversation )
    @controller = MessagesController.new
  end

  should_be_restful do |resource| 
    resource.parent     = [ :conversation ]        
    resource.create.params = { :message => "random message", :user => @user }
    resource.update.params = { :message => "Changed message", :user => @user }
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
