class AddAboutFieldToUsersTable < ActiveRecord::Migration
  def self.up
    add_column :users, :about, :string, :default => ""
  end

  def self.down
    remove_column :users, :about
  end
end
