class PopulateSubscriptionsTable < ActiveRecord::Migration
  def self.up
    # Conversation.find(:all, :include => { :messages => :user }, :conditions => {"users.id" => id})    
    # User.find(:all, :include => :messages, :conditions => {"messages.conversation_id" => id})


    Conversation.find(:all).each do |conversation|
      User.find(:all, :include => :messages, :conditions => {"messages.conversation_id" => conversation.id}).each do |user|
        
        subscription = Subscription.new
        subscription.user         = user
        subscription.conversation = conversation
        puts "user:" + user.id.to_s + " conversation:" + conversation.id.to_s
        subscription.save
      end
    end
  end

  def self.down
    Subscription.find(:all).each do |subscription|
      subscription.destroy
    end
  end
end
