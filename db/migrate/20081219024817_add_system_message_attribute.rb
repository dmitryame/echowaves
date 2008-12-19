class AddSystemMessageAttribute < ActiveRecord::Migration
  def self.up
    add_column :messages, :system_message, :boolean, :default => 0
  end

  def self.down
    remove_column :messages, :system_message        
  end
end
