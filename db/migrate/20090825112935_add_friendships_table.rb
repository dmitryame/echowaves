class AddFriendshipsTable < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer  "user_id",    :null => false
      t.integer  "friend_id",  :null => false
      t.timestamps
    end
    add_index :friendships, :user_id
    add_index :friendships, :friend_id
    
    Subscription.all.each do |s|
      convo = Conversation.find(s.conversation_id)
      if convo.personal_conversation
        user = User.find(s.user_id)
        user_to_follow = User.find(convo.user_id)
        user.follow_user(user_to_follow) unless user.id == user_to_follow.id
      end
    end
    
  end

  def self.down
    drop_table :friendships
  end
end
