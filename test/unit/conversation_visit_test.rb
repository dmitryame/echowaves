require 'test_helper'

class ConversationVisitTest < ActiveSupport::TestCase
  context "A Conversation_Visit instance" do    
     setup do
       @conversation_visit = Factory(:conversation_visit)
     end
     
     should_have_indices :user_id, :conversation_id, :created_at
     should_require_attributes :user_id, :conversation_id
   end
end
