class AddPersistenceTokenFieldToUsersTable < ActiveRecord::Migration
  def self.up
    add_column :users, :persistence_token, :string, :nil => false
    User.find(:all).each do |u|
      u.reset_persistence_token!
    end
  end

  def self.down
    remove_column :users, :persistence_token
  end
end
