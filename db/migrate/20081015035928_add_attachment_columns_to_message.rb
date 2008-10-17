class AddAttachmentColumnsToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :attachment_file_name, :string
    add_column :messages, :attachment_content_type, :string
    add_column :messages, :attachment_file_size, :integer
  end

  def self.down
    remove_column :messages, :attachment_file_name
    remove_column :messages, :attachment_content_type
    remove_column :messages, :attachment_file_size
  end
end
