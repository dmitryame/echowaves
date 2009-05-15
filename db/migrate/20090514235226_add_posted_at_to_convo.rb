class AddPostedAtToConvo < ActiveRecord::Migration
  def self.up
    add_column :conversations, :posted_at, :datetime
    add_index :conversations, :posted_at
  end

  def self.down
    remove_index :conversations, :posted_at
    remove_column :conversations, :posted_at
  end
end
