class InitializeUserNames < ActiveRecord::Migration
  def self.up
    User.find(:all).select{|u| u.name.blank?}.each do |u|
      u.name = u.login
      u.save
    end
  end

  def self.down
  end
end
