class AddWidthToImages < ActiveRecord::Migration
  def self.up
    add_column :messages, :attachment_width, :integer
  end

  def self.down
    drop_column :messages, :attachment_width
  end
end
