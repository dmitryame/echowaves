class RenameActivationCode < ActiveRecord::Migration
  def self.up
    rename_column :users, :activation_code, :perishable_token
  end

  def self.down
    rename_column :users, :perishable_token, :activation_code
  end
end
