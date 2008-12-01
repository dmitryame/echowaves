class SetLastMessageIdSubscriptionDefault < ActiveRecord::Migration
  def self.up
    change_column :subscriptions, :last_message_id, :integer, :default => 0 
  end

  def self.down
    change_column :subscriptions, :last_message_id, :integer
  end
end
