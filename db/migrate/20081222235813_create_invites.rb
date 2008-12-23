class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.references :user #invite this user
      t.column :requestor_id, :integer #who invited the user
      t.references :conversation            
      t.timestamps
    end
    add_index :invites, :user_id
    add_index :invites, :requestor_id
    add_index :invites, :conversation_id    
  end

  def self.down    
    drop_table :invites
  end
end
