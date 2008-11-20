require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  context "A Message instance" do    
    setup do
      @message = Factory(:message)
    end

    should_belong_to :conversation
    should_belong_to :user

    should_have_many :abuse_reports

    should_have_index :user_id
    should_have_index :conversation_id
    should_have_index :created_at

    should_require_attributes :message
    should_require_attributes :user_id, :conversation_id


  end    
end
