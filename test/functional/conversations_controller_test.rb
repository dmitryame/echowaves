require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  def setup
    @controller = ConversationsController.new
    create_user_and_authenticate
  end
   
  should_be_restful do |resource| 
    resource.create.params = { :login => "dmitry", :email => "dmitry@amelchenko.com", :password => "dmitrypassword", :password_confirmation => "dmitrypassword" }
    resource.update.params = { :login => "dmitry123", :email => "amelchenko@dmitry.com", :password => "dmitrypassword", :password_confirmation => "dmitrypassword" }
    resource.actions    = [
      :index
      # :show, 
      # :new, 
      # :edit, 
      # :update, 
      # :create, 
      # :destroy
      ]    
  end        

end
