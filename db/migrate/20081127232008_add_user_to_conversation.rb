class AddUserToConversation < ActiveRecord::Migration
  def self.up
    add_column :conversations, :user_id, :integer
    add_index :conversations, :user_id    
    
    #populate user_id in convo
    conversations = Conversation.find(:all)
    conversations.each do |convo|
      puts convo.id
      message = Message.find_by_conversation_id(convo.id, :order => "id ASC")
      user = message.user if message != nil
      convo.user_id = user.id if user != nil
      convo.save      
    end
    
  end

  def self.down
    remove_index :conversations, :user_id
    remove_column :conversations, :user_id
  end
end
