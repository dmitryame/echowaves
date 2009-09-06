class RemoveSystemMessagesColumnFromMessageModel < ActiveRecord::Migration
  def self.up
    remove_column :messages, :system_message
  end

  def self.down
  end
end
