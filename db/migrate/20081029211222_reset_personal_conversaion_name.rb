class ResetPersonalConversaionName < ActiveRecord::Migration
  def self.up
    Conversation.find(:all).select{|c| c.personal_conversation == true}.each do |conversation|
      puts conversation.name + " = " + conversation.messages.first.user.login
      conversation.name = conversation.messages.first.user.login
      conversation.save
    end
  end

  def self.down
  end
end
