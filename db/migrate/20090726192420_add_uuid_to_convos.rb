class AddUuidToConvos < ActiveRecord::Migration
  def self.up
    add_column :conversations, :uuid, :string
    
    Conversation.find_each(:batch_size => 100) do |c|  
      c.reset_uuid!
    end
  end

  def self.down
    remove_column :conversations, :uuid
  end
end
