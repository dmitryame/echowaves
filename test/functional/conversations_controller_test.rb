require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  def setup
    @controller = ConversationsController.new
    create_user_and_authenticate
    @conversation = Factory(:conversation)
    
  end
   
  should_be_restful do |resource| 
    resource.create.params = { :name => "random conversation" }
    resource.update.params = { :name => "random conversation changed" }
  end        

end
