require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A User instance" do    
    setup do
      @user = Factory.create(:user)
    end
    
    should_have_index :login
    should_have_index :email
    should_have_index :crypted_password
    

    
    should_require_attributes :login
    should_require_attributes :email

    should_require_unique_attributes :login, :email

    
    should_ensure_length_in_range :login, (3..40) 
    should_ensure_length_in_range :email, (6..100) 
    should_ensure_length_in_range :name, (0..100) 
          
    should_have_many :messages

    should_belong_to :personal_conversation
    
    should "have conversations" do 
      @conversation1 = Factory.create(:conversation, :name => "converstaion1")
      @conversation2 = Factory.create(:conversation, :name => "converstaion2")
      @conversation3 = Factory.create(:conversation, :name => "converstaion3")
      @message1 = Factory.create(:message, :conversation => @conversation1, :user => @user)
      @message2 = Factory.create(:message, :conversation => @conversation2, :user => @user)
      @message3 = Factory.create(:message, :conversation => @conversation3, :user => @user)
      @message4 = Factory.create(:message, :conversation => @conversation2, :user => @user)
      @message5 = Factory.create(:message, :conversation => @conversation3, :user => @user)
      @message6 = Factory.create(:message, :conversation => @conversation1, :user => @user)
      @message7 = Factory.create(:message, :conversation => @conversation1, :user => @user)
      @message8 = Factory.create(:message, :conversation => @conversation2, :user => @user)
      @message9 = Factory.create(:message, :conversation => @conversation1, :user => @user)
      
      assert_equal @user.conversations.size, 3 + 1#it's actually one more, because the user has his own conversation automatically created
    end

    should_have_many :subscriptions
    should_have_many :conversations, :through => :subscriptions
    
    should_have_many :conversation_visits

    should_have_many :recent_conversations, :through => :conversation_visits
  end    
end
