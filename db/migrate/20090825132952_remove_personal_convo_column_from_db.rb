class RemovePersonalConvoColumnFromDb < ActiveRecord::Migration
  def self.up
    remove_column :conversations, :personal_conversation
    remove_column :users, :personal_conversation_id
  end

  def self.down
  end
end
