class AddEmailNotificationsFlag < ActiveRecord::Migration
  
  class User < ActiveRecord::Base; end;
  
  def self.up
    add_column :users, :receive_email_notifications, :boolean, :default => true
  end

  def self.down
    remove_column :users, :receive_email_notifications
  end
end
