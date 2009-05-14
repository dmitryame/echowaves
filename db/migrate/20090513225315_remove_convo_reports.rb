class RemoveConvoReports < ActiveRecord::Migration
  def self.up
    remove_column :conversations, :abuse_report_id
    remove_index :abuse_reports, :conversation_id
    remove_column :abuse_reports, :conversation_id
  end

  def self.down
    add_column :abuse_reports, :conversation_id, :integer
    add_index :abuse_reports, :conversation_id    
    add_column :conversations, :abuse_report_id, :integer
  end
end
