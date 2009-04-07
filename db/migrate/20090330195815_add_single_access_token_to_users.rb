class AddSingleAccessTokenToUsers < ActiveRecord::Migration
  
  class User < ActiveRecord::Base; acts_as_authentic; end;
  
  def self.up
    add_column :users, :single_access_token, :string,  :null => false
    User.all.each do |user|  
      user.reset_single_access_token!
    end
  end

  def self.down
    remove_column :users, :single_access_token
  end
end
