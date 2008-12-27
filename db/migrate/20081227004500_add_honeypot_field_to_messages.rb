class AddHoneypotFieldToMessages < ActiveRecord::Migration
  def self.up
    # some spam bots are really stupid, they put their spam stuff in every field in comments forms,
    # so let's create a honeypot field and check it and verify that it has not been
    # filled before creating the message
    add_column :messages, :something, :string, :default => ""
  end

  def self.down
    remove_column :messages, :something
  end
end
