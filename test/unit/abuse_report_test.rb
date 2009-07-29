# == Schema Info
# Schema version: 20090728125500
#
# Table name: abuse_reports
#
#  id         :integer(4)      not null, primary key
#  message_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime

require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  context "A AbuseReportTest instance" do    
     setup do
       @abuse_report = Factory(:abuse_report)
     end
     subject { @abuse_report }
     
     should_belong_to :user
     should_belong_to :message
          
     should_validate_presence_of :user_id

     should_have_db_indices :user_id, :message_id, :created_at
   end
end
