require 'test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  context "A AbuseReportTest instance" do    
     setup do
       @abuse_report = Factory(:abuse_report)
     end
     
     should_belong_to :user
     should_belong_to :message
          
     should_require_attributes :user_id, :message_id

     should_have_indices :user_id, :message_id, :created_at
   end
end
