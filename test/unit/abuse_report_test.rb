require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  context "A AbuseReportTest instance" do    
     setup do
       @abuse_report = Factory(:abuse_report)
     end
     
     should_belong_to :user
     should_belong_to :message
     should_belong_to :conversation
          
     should_require_attributes :user_id

     should_have_indices :user_id, :message_id, :conversation_id, :created_at
   end
end
