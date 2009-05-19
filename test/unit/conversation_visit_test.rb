# == Schema Info
# Schema version: 20090514235226
#
# Table name: conversation_visits
#
#  id              :integer(4)      not null, primary key
#  conversation_id :integer(4)
#  user_id         :integer(4)
#  visits_count    :integer(4)      default(1)
#  created_at      :datetime
#  updated_at      :datetime

require File.dirname(__FILE__) + '/../test_helper'

class ConversationVisitTest < ActiveSupport::TestCase
  context "A Conversation_Visit instance" do    
     setup do
       @conversation_visit = Factory(:conversation_visit)
     end
     
     should_belong_to :user
     should_belong_to :conversation
     
     should_validate_presence_of :conversation_id

     should_have_indices :user_id, :conversation_id, :created_at
   end
end
