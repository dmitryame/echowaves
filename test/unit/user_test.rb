require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A User instance" do    
    setup do
      @user = Factory(:user)
    end
    
    should_require_attributes :login
    should_require_attributes :email
            
  end    
end
