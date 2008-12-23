class FixEditedLoginNames < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.update_attributes( :login => u.personal_conversation.name ) unless (u.personal_conversation == nil || u.login == u.personal_conversation.name)
    end
  end

  def self.down
  end
end
