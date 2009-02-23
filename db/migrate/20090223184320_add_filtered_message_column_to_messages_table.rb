class AddFilteredMessageColumnToMessagesTable < ActiveRecord::Migration
  # disable validations so the migration will pass
  class Message < ActiveRecord::Base
    auto_html_for(:message) do
      html_escape
      youtube(:width => 400, :height => 250)
      vimeo
      image
      link(:target => "_blank", :rel => "nofollow")
      simple_format
    end
  end
  
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
