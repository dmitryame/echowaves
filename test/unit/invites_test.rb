require 'test_helper'

class InvitesTest < ActiveSupport::TestCase
  context "An invite instance" do    
     setup do
       @invite = Factory(:invite)
     end
     
     should_belong_to :user
     should_belong_to :invited_by
     should_belong_to :conversation
     
     should_have_indices :user_id, :invited_by, :conversation_id
     should_require_attributes :user_id, :invited_by, :conversation_id
   end
end
