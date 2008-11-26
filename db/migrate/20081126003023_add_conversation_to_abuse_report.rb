class AddConversationToAbuseReport < ActiveRecord::Migration
  def self.up
    add_column :abuse_reports, :conversation_id, :integer
    add_index :abuse_reports, :conversation_id    

    add_column :conversations, :abuse_report_id, :integer
    remove_column :messages, :deactivated_at
  end

  def self.down
    add_column :messages, :deactivated_at, :datetime
    
    remove_column :conversations, :abuse_report_id

    remove_index :abuse_reports, :conversation_id
    remove_column :abuse_reports, :conversation_id
  end
end
