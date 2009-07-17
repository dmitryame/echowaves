class CreateRudeQueues < ActiveRecord::Migration
  def self.up
    create_table :rude_queues do |t|
      t.string :queue_name
      t.text :data
      t.boolean :processed, :default => false, :null => false

      t.timestamps
    end
    add_index :rude_queues, :processed
    add_index :rude_queues, [:queue_name, :processed]
  end

  def self.down
    drop_table :rude_queues
  end
end
