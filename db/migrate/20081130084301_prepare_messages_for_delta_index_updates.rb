class PrepareMessagesForDeltaIndexUpdates < ActiveRecord::Migration
  def self.up
    add_column :messages, :delta, :boolean, :default => false
  end

  def self.down
    remove_column :messages, :delta
  end
end
