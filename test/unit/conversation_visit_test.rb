require File.dirname(__FILE__) + '/../test_helper'

class ConversationVisitTest < ActiveSupport::TestCase
  context "A Conversation_Visit instance" do    
     setup do
       @conversation_visit = Factory(:conversation_visit)
     end
     
     should_belong_to :user
     should_belong_to :conversation
     
     should_require_attributes :conversation_id

     should_have_indices :user_id, :conversation_id, :created_at
   end
end
