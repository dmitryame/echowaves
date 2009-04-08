class AddSingleAccessTokenToUsers < ActiveRecord::Migration  
  def self.up
    add_column :users, :single_access_token, :string,  :null => false
  end

  def self.down
    remove_column :users, :single_access_token
  end
end
