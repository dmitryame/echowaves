class AddHoneypotFieldToConvos < ActiveRecord::Migration
  def self.up
    # some spam bots are really stupid, they put their spam stuff in every field in comment forms,
    # so let's create a honeypot field and check it and verify that it has not been
    # filled before creating the convo
    add_column :conversations, :something, :string, :default => ""
  end

  def self.down
    remove_column :conversations, :something
  end
end
