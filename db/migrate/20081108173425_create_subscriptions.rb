class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t| # this table is a many to many association link between users and conversations.
      t.references :user
      t.references :conversation
      t.datetime :activated_at # the name of the attibute is a bit missleaading (maybe), what it really mean is the last time the user switched to this conversion to make it active. The assumtion is that if the conversation for a user has the latest activated_ad (among all different conversations for this user), there is no need to track the last message id
      t.integer :last_message_id #is used to track how many messages are unread. 

      t.timestamps
    end
    
    add_index :subscriptions, :user_id
    add_index :subscriptions, :conversation_id
    add_index :subscriptions, :activated_at
    
  end

  def self.down
    drop_table :subscriptions
  end
end
