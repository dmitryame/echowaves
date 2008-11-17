class CreateAbuseReports < ActiveRecord::Migration
  def self.up
    create_table :abuse_reports do |t|
      t.references :message
      t.references :user

      t.timestamps
    end
    add_index :abuse_reports, :created_at
    add_index :abuse_reports, :message_id
    add_index :abuse_reports, :user_id

    add_column :messages, :deactivated_at, :datetime
    add_column :messages, :abuse_report_id, :integer
        
  end

  def self.down
    remove_column :messages, :deactivated_at
    remove_column :messages, :abuse_report_id

    remove_index :abuse_reports, :created_at
    remove_index :abuse_reports, :message_id
    remove_index :abuse_reports, :user_id
    
    drop_table :abuse_reports
  end
end
