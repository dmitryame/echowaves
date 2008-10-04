require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  context "A Conversation instance" do    
    setup do
      @conversation = Factory.create(:conversation)
    end
    
    should_require_attributes :name
    should_require_unique_attributes :name

    should_have_index :name
    should_have_index :created_at
    
    should_ensure_length_in_range :name, (8..100) 
 
    should_have_many :messages
             
  end    
end
