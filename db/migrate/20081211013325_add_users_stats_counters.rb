class AddUsersStatsCounters < ActiveRecord::Migration
  def self.up
    add_column :users, :messages_count, :integer, :default => 0
    add_column :users, :subscriptions_count, :integer, :default => 0
    add_column :users, :conversations_count, :integer, :default => 0
    
    User.reset_column_information
    User.find(:all).each do |u|
      User.update_counters u.id, :messages_count => u.messages.length
      User.update_counters u.id, :subscriptions_count => u.subscriptions.length
      User.update_counters u.id, :conversations_count => u.conversations.length
    end
    
  end

  def self.down
    remove_column :users, :messages_count
    remove_column :users, :subscriptions_count
    remove_column :users, :conversations_count
  end
end
