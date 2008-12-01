require File.dirname(__FILE__) + '/../test_helper'

class ConversationTest < ActiveSupport::TestCase
  context "A Conversation instance" do    
    setup do
      @conversation = Factory.create(:conversation)
    end
    
    should_require_attributes :name, :description
    
    should_require_unique_attributes :name

    should_have_index :name
    should_have_index :created_at
    
    should_ensure_length_in_range :name, (3..100) 
 
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

    should_belong_to :parent_message #parent message it was spawned from
    should_have_index :parent_message_id
    
    should_belong_to :user
    should_have_index :user_id
  end
  
  context "A read only conversation" do  
    setup do
      @owner = Factory.create(:user, :login => "user1")
      @conversation = Factory.create(:conversation, :user => @owner)      
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

  context "A visit to a conversation" do
    setup do
      @conversation = Factory.create(:conversation)
      @user = Factory.create(:user, :login => 'user1')
    end

    should "create a new ConversationVisit on a users first visit" do
      assert_equal ConversationVisit.all.length, 0
      @conversation.add_visit(@user)
      assert_equal ConversationVisit.all.length, 1
    end

    should "update the existing ConversationVisit record on repeat visit" do
      @cv = Factory.create(:conversation_visit, :conversation => @conversation, :user => @user)
      pre_size = ConversationVisit.all.length
      @conversation.add_visit(@user)
      assert_equal ConversationVisit.all.length, pre_size
    end
  end
  
end
