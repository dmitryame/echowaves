class CleanupNeverusedColumns < ActiveRecord::Migration
  def self.up
    remove_column :messages, :attachment_updated_at
    remove_column :messages, :parent_id
  end

  def self.down
    add_column :messages, :attachment_updated_at, :datetime
    add_column :messages, :parent_id, :integer
  end
end
