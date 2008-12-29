class AddHoneypotFieldToUsers < ActiveRecord::Migration
  def self.up
    # some spam bots are really stupid, they put their spam stuff in every field in signup forms,
    # so let's create a honeypot field and check it and verify that it has not been
    # filled before creating the user
    add_column :users, :something, :string, :default => ""
  end

  def self.down
    remove_column :users, :something
  end
end
