class AddFewIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :email
    add_index :users, :crypted_password
    add_index :conversations, :name
    add_index :conversations, :created_at
    add_index :messages, :user_id
    add_index :messages, :conversation_id
    add_index :messages, :created_at
  end

  def self.down
    remove_index :users, :email
    remove_index :users, :crypted_password
    remove_index :conversations, :name
    remove_index :conversations, :created_at
    remove_index :messages, :user_id
    remove_index :messages, :conversation_id
    remove_index :messages, :created_at
  end
end
