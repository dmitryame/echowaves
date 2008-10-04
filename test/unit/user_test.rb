require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A User instance" do    
    setup do
      @user = Factory.create(:user)
    end
    
    should_have_index :login
    should_have_index :email
    should_have_index :crypted_password
    

    
    should_require_attributes :login
    should_require_attributes :email

    should_require_unique_attributes :login, :email

    
    should_ensure_length_in_range :login, (3..40) 
    should_ensure_length_in_range :email, (6..100) 
    should_ensure_length_in_range :name, (0..100) 
          
    should_have_many :messages
    
  end    
end
