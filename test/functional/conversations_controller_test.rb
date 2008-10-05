require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  def setup
    #authenticate
    create_user_and_authenticate
    @conversation = Factory(:conversation)
    @controller = ConversationsController.new
  end
   
  should_be_restful do |resource| 
    resource.create.params = { :name => "random conversation" }
    resource.update.params = { :name => "random conversation changed" }
    resource.actions    = [
      :index,
      :show, 
      :new, 
      :edit, 
      :update, 
      :create, 
      :destroy
      ]    
  end        

end
