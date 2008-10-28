require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  def setup
    #authenticate
    create_user_and_authenticate
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

end
