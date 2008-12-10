class AddMessageCounterToConvo < ActiveRecord::Migration
  def self.up
    add_column :conversations, :messages_count, :integer, :default => 0 
    
    Conversation.find(:all).map {|convo| puts convo.messages(:refresh).size}    
  end

  def self.down
    remove_column :conversations, :messages_count
  end
end
