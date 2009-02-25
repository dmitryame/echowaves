class AddPrivateFlagToConvos < ActiveRecord::Migration
  def self.up
    add_column :conversations, :private, :boolean, :default => false
  end

  def self.down
    remove_column :conversations, :private
  end
end
