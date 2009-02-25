class AddTokenToInvite < ActiveRecord::Migration
  def self.up
    add_column :invites, :token, :string
  end

  def self.down
    remove_column :invites, :token
  end
end
