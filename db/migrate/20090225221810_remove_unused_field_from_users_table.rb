class RemoveUnusedFieldFromUsersTable < ActiveRecord::Migration
  def self.up
    remove_column :users, :password_reset_code
  end

  def self.down
  end
end
