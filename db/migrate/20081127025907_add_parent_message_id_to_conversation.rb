class AddParentMessageIdToConversation < ActiveRecord::Migration
  def self.up
    add_column :conversations, :parent_message_id, :integer
    add_index :conversations, :parent_message_id    
  end

  def self.down
    remove_index :conversations, :parent_message_id
    remove_column :conversations, :parent_message_id
  end
end
