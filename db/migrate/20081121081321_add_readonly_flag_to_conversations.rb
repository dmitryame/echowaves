class AddReadonlyFlagToConversations < ActiveRecord::Migration
  def self.up
    add_column :conversations, :read_only, :boolean, :default => false
  end

  def self.down
    remove_column :conversations, :read_only
  end
end
