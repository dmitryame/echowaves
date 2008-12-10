class AddMessageCounterToConvo < ActiveRecord::Migration
  def self.up
    add_column :conversations, :messages_count, :integer, :default => 0 
    
    Conversation.reset_column_information
    Conversation.find(:all).each do |convo| 
      Conversation.update_counters convo.id, :messages_count => convo.messages.count
    end
  end

  def self.down
    remove_column :conversations, :messages_count
  end
end
