class AddAttachmentHeightToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :attachment_height, :integer
  end

  def self.down
    drop_column :messages, :attachment_height
  end
end
