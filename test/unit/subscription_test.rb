require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  context "A Subscription instance" do    
     setup do
       @subscription = Factory(:subscription)
     end
     
     should_belong_to :user
     should_belong_to :conversation
     should_have_indices :user_id, :conversation_id, :activated_at
     should_require_attributes :user_id, :conversation_id
   end
end
