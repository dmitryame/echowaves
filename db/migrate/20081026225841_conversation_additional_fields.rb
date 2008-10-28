class ConversationAdditionalFields < ActiveRecord::Migration
  def self.up
    add_column :conversations, :description, :text
    add_column :conversations, :personal_conversation, :boolean, :default => 0
    add_column :users, :personal_conversation_id, :integer # users conversation that is automatically created when the user is created    
  end

  def self.down
    remove_column :conversations, :description
    remove_column :conversations, :personal_conversation    
    remove_column :users, :conversation_id
  end
end
