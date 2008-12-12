class AddSubscriptionCounterCacheToConvo < ActiveRecord::Migration
  def self.up
    add_column :conversations, :subscriptions_count, :integer, :default => 0

    Conversation.reset_column_information
    Conversation.find(:all).each do |c|
      Conversation.update_counters c.id, :subscriptions_count => c.subscriptions.length
    end
  end

  def self.down
    remove_column :conversations, :subscriptions_count    
  end
end
