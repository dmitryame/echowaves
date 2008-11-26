require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  context "A Conversation instance" do    
    setup do
      @conversation = Factory.create(:conversation)
    end
    
    should_require_attributes :name, :description
    
    should_require_unique_attributes :name

    should_have_index :name
    should_have_index :created_at
    
    should_ensure_length_in_range :name, (8..100) 
    # should_ensure_length_in_range :description, (0..10000) 
 
    should_have_many :messages
    
    should "have users in conversations" do 
      @user1 = Factory.create(:user, :login => "user1")
      @user2 = Factory.create(:user, :login => "user2")
      @user3 = Factory.create(:user, :login => "user3")
      @message1 = Factory.create(:message, :conversation => @conversation, :user => @user1)
      @message2 = Factory.create(:message, :conversation => @conversation, :user => @user2)
      @message3 = Factory.create(:message, :conversation => @conversation, :user => @user1)
      @message4 = Factory.create(:message, :conversation => @conversation, :user => @user1)
      @message5 = Factory.create(:message, :conversation => @conversation, :user => @user2)
      @message6 = Factory.create(:message, :conversation => @conversation, :user => @user2)
      @message7 = Factory.create(:message, :conversation => @conversation, :user => @user3)
      @message8 = Factory.create(:message, :conversation => @conversation, :user => @user3)
      @message9 = Factory.create(:message, :conversation => @conversation, :user => @user1)
      
      assert_equal @conversation.users.size, 3
    end

    should_have_many :subscriptions
    should_have_many :users, :through => :subscriptions
    should_have_many :recent_followers, :through => :subscriptions          
    
    should_have_many :abuse_reports
    should_belong_to :abuse_report
    
  end
  
  context "A read only conversation" do  
    setup do
      @conversation = Factory.create(:conversation)
      @owner = Factory.create(:user, :login => "user1")
      @user2 = Factory.create(:user, :login => "user2")
      @message1 = Factory.create(:message, :conversation => @conversation, :user => @owner)
      @conversation.update_attributes(:read_only => true)
    end
    
    should "be writable by the owner" do
      assert @conversation.writable_by?(@owner)
    end
    
    should "not be writable by the users" do
      assert !@conversation.writable_by?(@user2)
    end
  end
  
  context "A writable conversation" do
    setup do
      @conversation = Factory.create(:conversation)
      @owner = Factory.create(:user, :login => "user1")
      @user2 = Factory.create(:user, :login => "user2")
      @message1 = Factory.create(:message, :conversation => @conversation, :user => @owner)
      @conversation.update_attributes(:read_only => false)
    end
    
    should "be writable by the owner" do
      assert @conversation.writable_by?(@owner)
    end
    
    should "be writable by the users" do
      assert @conversation.writable_by?(@user2)
    end
  end
  
end
