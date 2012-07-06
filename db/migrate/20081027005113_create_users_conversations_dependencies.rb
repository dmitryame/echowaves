class CreateUsersConversationsDependencies < ActiveRecord::Migration
  def self.up
    Conversation.find(:all).select{|c| c.description.blank?}.each do |conversation|
      conversation.description = conversation.name
      conversation.save
    end
    User.find(:all).select{|u| u.personal_conversation_id.blank?}.each do |u|
      conversation = Conversation.new
      conversation.name = "Personal conversation for " + u.login
      conversation.description = "This is a personal conversation for " + u.login + ". If you wish to collaborate with " + u.login + ", do it here."
      conversation.personal_conversation = true;
      conversation.created_by = u #this gets propageted to first message in the conversation which makes it an owner.
      conversation.save
      u.personal_conversation_id = conversation.id
      u.save
    end
  end

  def self.down
  end
end
