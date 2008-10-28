class CreateUsersConversationsDependencies < ActiveRecord::Migration
  def self.up
    Conversation.find(:all).select{|c| c.user_id.blank?}.each do |conversation|
      conversation.description = conversation.name
      conversation.save
    end
    User.find(:all).select{|u| u.conversation_id.blank?}.each do |u|
      conversation = Conversation.new
      conversation.name = u.login + '\'s conversation'
      conversation.description = conversation.name
      conversation.save
      u.personal_conversation_id = conversation.id
      u.save      
    end    
  end

  def self.down
  end
end
