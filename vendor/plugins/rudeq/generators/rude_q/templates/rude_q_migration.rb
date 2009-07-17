class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
      t.string :queue_name
      t.text :data
      t.boolean :processed, :default => false, :null => false
<% unless options[:skip_timestamps] %>
      t.timestamps
<% end -%>
    end
    add_index :<%= table_name %>, :processed
    add_index :<%= table_name %>, [:queue_name, :processed]
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
