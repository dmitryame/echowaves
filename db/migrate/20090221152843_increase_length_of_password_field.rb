class IncreaseLengthOfPasswordField < ActiveRecord::Migration
  def self.up
    change_column :users, :crypted_password, :string, :limit => 128, :null => false, :default => ""
    change_column :users, :salt, :string, :limit => 128, :null => false, :default => ""
  end

  def self.down
  end
end
