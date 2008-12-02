class PrepareConversationsForDeltaIndexUpdates < ActiveRecord::Migration
  def self.up
    add_column :conversations, :delta, :boolean, :default => false
  end

  def self.down
    remove_column :conversations, :delta
  end
end
