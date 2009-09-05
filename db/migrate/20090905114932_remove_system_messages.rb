class RemoveSystemMessages < ActiveRecord::Migration
  def self.up
    Message.find_each(:conditions => {:system_message => true}, :batch_size => 100) do |msg|  
      msg.destroy
    end
  end

  def self.down
  end
end
