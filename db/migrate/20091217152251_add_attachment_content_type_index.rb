class AddAttachmentContentTypeIndex < ActiveRecord::Migration
  def self.up
    add_index :messages, :attachment_content_type
  end

  def self.down
    remove_index :messages, :attachment_content_type
  end
end
