class RegenerateTokens < ActiveRecord::Migration

  class User < ActiveRecord::Base; acts_as_authentic; end;

  def self.up
    User.all.each do |user|  
      user.reset_single_access_token!
    end
  end

  def self.down
  end
end
