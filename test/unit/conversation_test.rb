require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  context "A Conversation instance" do    
    setup do
      @conversation = Factory.create(:conversation)
    end
    
    should_require_attributes :name
            
  end    
end
