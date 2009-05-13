class AddSubscriptionUniqueIndex < ActiveRecord::Migration
  def self.up
    add_index :subscriptions, [:user_id, :conversation_id], :unique => true
  end

  def self.down
    remove_index :subscriptions, :column => [:user_id, :conversation_id]
  end
end
