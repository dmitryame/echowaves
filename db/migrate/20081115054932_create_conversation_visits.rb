class CreateConversationVisits < ActiveRecord::Migration
  def self.up
    create_table :conversation_visits do |t|
      t.references :user
      t.references :conversation

      t.timestamps
    end
    
    add_index :conversation_visits, :created_at
    add_index :conversation_visits, :user_id
    add_index :conversation_visits, :conversation_id
  end

  def self.down
    remove_index :conversation_visits, :created_at
    remove_index :conversation_visits, :user_id
    remove_index :conversation_visits, :conversation_id
    
    drop_table :conversation_visits
  end
end
