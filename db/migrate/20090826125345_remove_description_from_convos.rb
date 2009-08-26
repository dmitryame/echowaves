class RemoveDescriptionFromConvos < ActiveRecord::Migration
  def self.up
    remove_column :conversations, :description
  end

  def self.down
  end
end
