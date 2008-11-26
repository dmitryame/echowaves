class AddConversationToAbuseReport < ActiveRecord::Migration
  def self.up
    add_column :abuse_reports, :conversation_id, :integer
    add_index :abuse_reports, :conversation_id    
  end

  def self.down
    remove_index :abuse_reports, :conversation_id
    remove_column :abuse_reports, :conversation_id
  end
end
