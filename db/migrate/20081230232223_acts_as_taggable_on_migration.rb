class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    #first drop existing tables created by acts_as_taggable_on_steroids
    drop_table :taggings
    drop_table :tags
    
    create_table :tags do |t|
      t.column :name, :string
    end
    
    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      t.column :tagger_id, :integer
      t.column :tagger_type, :string
      
      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :taggable_type, :string
      t.column :context, :string
      
      t.column :created_at, :datetime
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
    
    #tag personal convols
    Conversation.personal.each do |c|
      puts c.name
      c.user.tag(c, :with => "personal_convo", :on => :tags)
    end
    Conversation.all.each do |c|
      puts c.name
      c.user.tag(c, :with => c.tag_list.to_s  + ", " + c.user.login, :on => :tags)      
    end
    
  end
  
  def self.down
    drop_table :taggings
    drop_table :tags
    
    #return to acts_as_taggable_on_steroids
    create_table :tags do |t|
      t.column :name, :string
    end
    
    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      
      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :taggable_type, :string
      
      t.column :created_at, :datetime
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
    
  end
end
