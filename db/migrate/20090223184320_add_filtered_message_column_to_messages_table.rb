class AddFilteredMessageColumnToMessagesTable < ActiveRecord::Migration
  def self.up
    add_column :messages, :message_html, :text
    # generate all the markup for the existing messages
    Message.all.each do |m|
      m.save!
    end
  end

  def self.down
    remove_column :messages, :message_html
  end
end
