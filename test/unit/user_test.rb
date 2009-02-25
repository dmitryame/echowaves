require File.dirname(__FILE__) + '/../test_helper'

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
    
    should "have subscriptions" do 
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
      
      assert_equal @user.subscribed_conversations.size, 3
    end

    should_have_many :subscriptions
    should_have_many :subscribed_conversations, :through => :subscriptions
    should_have_many :conversations
    
    should_have_many :conversation_visits

    should_have_many :recent_conversations, :through => :conversation_visits
    
    should "be able to suscribe to a convo if the convo is not private" do
      @user = Factory.create(:user, :login => "user")
      @conversation = Factory.create(:conversation, :name => "converstaion")
      assert @user.follow(@conversation)
    end
    
    should "be able to suscribe to a convo if the convo is private and the user is the owner" do
      @user = Factory.create(:user, :login => "user")
      @conversation = Factory.create(:conversation, :name => "converstaion", :user => @user, :private => true)
      assert @user.follow(@conversation)
    end
    
    should "not be able to suscribe to a convo if the convo is private" do
      @user = Factory.create(:user, :login => "user")
      @conversation = Factory.create(:conversation, :name => "converstaion", :private => true)
      assert !@user.follow(@conversation)
    end
    
    should "be able to suscribe to a convo if the convo is private and the user have a invitation token" do
      @user = Factory.create(:user, :login => "user")
      @user.reset_activation_code!
      @conversation = Factory.create(:conversation, :name => "converstaion", :private => true)
      assert @user.follow(@conversation, @user.activation_code)
    end
    
    should "not be able to suscribe to a convo if the convo is private and the user have a wrong invitation token" do
      @user = Factory.create(:user, :login => "user")
      @user.reset_activation_code!
      @conversation = Factory.create(:conversation, :name => "converstaion", :private => true)
      assert !@user.follow(@conversation, "hacked_activation_code")
    end
    
    should "be valid if honeypot field is blank" do
      assert @user.valid?
    end
    
    should "not be valid if honeypot field is not blank" do
      @user.something = "spam"
      assert !@user.valid?
    end
    
    should "not change the login" do
      @original_login = @user.login
      @user.update_attributes( :login => 'changed' )
      assert_equal @original_login, @user.login
    end
  end
  
  context "xml serialization, an User instance" do
    setup do
      @user = Factory.create( :user )
      @xml = @user.to_xml
    end
    
    should "serialize the login" do
      assert_match %r{<login>}, @xml
    end
    
    should "serialize the convos count" do
      assert_match %r{<conversations-count}, @xml
    end
    
    should "serialize the date of creation" do
      assert_match %r{<created-at}, @xml
    end
    
    should "serialize the id" do
      assert_match %r{<id}, @xml
    end
    
    should "serialize the messages count" do
      assert_match %r{<messages-count}, @xml
    end
    
    should "serialize the name" do
      assert_match %r{<name>}, @xml
    end
    
    should "serialize the subscriptions count" do
      assert_match %r{<subscriptions-count}, @xml
    end
    
    should "serialize the personal conversation id" do
      assert_match %r{<personal-conversation-id}, @xml
    end
    
    should "serialize the time zone" do
      assert_match %r{<time-zone}, @xml
    end
    
    should "serialize the update date" do
      assert_match %r{<updated-at}, @xml
    end
    # don't show this sensible data
    
    should "not serialize the activation date" do
      assert_no_match %r{<activated-at}, @xml
    end
    
    should "not serialize the activation code" do
      assert_no_match %r{<activation-code}, @xml
    end
    
    should "not serialize the crypted password" do
      assert_no_match %r{<crypted-password>}, @xml
    end
    
    should "not serialize the email" do
      assert_no_match %r{<email>}, @xml
    end
    
    should "not serialize the password reset code" do
      assert_no_match %r{<password-reset-code}, @xml
    end
    
    should "not serialize the remember token" do
      assert_no_match %r{<remember-token}, @xml
    end
    
    should "not serialize the remember token expiration date" do
      assert_no_match %r{<remember-token-expires-at}, @xml
    end
    
    should "not serialize the password salt" do
      assert_no_match %r{<salt}, @xml
    end
  end
  
  context "mark last viewed as read" do
    setup do
      @user = Factory.create( :user )
    end

    should "do nothing if user has no subscriptions" do
      assert_equal 0, @user.subscriptions.size
      @user.mark_last_viewed_as_read
      assert_equal 0, @user.subscriptions.size
    end

    should "update last viewed subscription" 
  end
end
