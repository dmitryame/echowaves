class UniqueEmailIndex < ActiveRecord::Migration
  def self.up
    remove_index :users, :column => :email
    add_index :users, :email, :unique => true
  end

  def self.down
    remove_index :users, :column => :email
    add_index :users, :email
  end
end
