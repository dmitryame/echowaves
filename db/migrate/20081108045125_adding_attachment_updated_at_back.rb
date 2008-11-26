class AddingAttachmentUpdatedAtBack < ActiveRecord::Migration
  def self.up
    add_column :messages, :attachment_updated_at, :datetime
  end

  def self.down
    remove_column :messages, :attachment_updated_at
  end
end
