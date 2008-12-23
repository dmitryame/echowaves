require File.dirname(__FILE__) + '/../test_helper'

class InviteTest < ActiveSupport::TestCase
  context "An invite instance" do    
     setup do
       user = Factory.create(:user, :login => "user1")              
       @invite = Factory.create(:invite, :requestor => user)
     end
     
     should_belong_to :user
     should_belong_to :requestor
     should_belong_to :conversation
     
     should_have_indices :user_id, :requestor_id, :conversation_id
     should_require_attributes :user_id, :requestor_id, :conversation_id
   end
end
