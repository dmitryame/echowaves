# == Schema Info
# Schema version: 20090514235226
#
# Table name: users
#
#  id                          :integer(4)      not null, primary key
#  personal_conversation_id    :integer(4)
#  conversations_count         :integer(4)      default(0)
#  crypted_password            :string(128)     not null, default("")
#  email                       :string(100)
#  login                       :string(40)
#  messages_count              :integer(4)      default(0)
#  name                        :string(100)     default("")
#  perishable_token            :string(40)
#  persistence_token           :string(255)
#  receive_email_notifications :boolean(1)      default(TRUE)
#  remember_token              :string(40)
#  salt                        :string(128)     not null, default("")
#  single_access_token         :string(255)     not null
#  something                   :string(255)     default("")
#  subscriptions_count         :integer(4)      default(0)
#  time_zone                   :string(255)     default("UTC")
#  activated_at                :datetime
#  created_at                  :datetime
#  remember_token_expires_at   :datetime
#  updated_at                  :datetime

require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  context "A User instance" do    
    setup do
      @user = Factory.create(:user)
    end
    subject { @user }
    
    should_have_db_index :login
    should_have_db_index :email
    should_have_db_index :crypted_password
    

    
    should_validate_presence_of :login
    should_validate_presence_of :email

    should_validate_uniqueness_of :login, :email

    
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
      
      assert_equal 3, @user.subscribed_conversations.size
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
      @user.reset_perishable_token!
      @conversation = Factory.create(:conversation, :name => "converstaion", :private => true)
      @invite = Factory.create(:invite, :user => @user, :conversation => @conversation, :token => @user.perishable_token, :requestor_id => 13)
      assert @user.follow(@conversation, @invite.token)
    end
    
    should "not be able to suscribe to a convo if the convo is private and the user have a wrong invitation token" do
      @user = Factory.create(:user, :login => "user")
      @user.reset_perishable_token!
      @conversation = Factory.create(:conversation, :name => "converstaion", :private => true)
      assert !@user.follow(@conversation, "hacked_perishable_token")
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
    
    should "not serialize the remember token" do
      assert_no_match %r{<remember-token}, @xml
    end
    
    should "not serialize the perishable token" do
      assert_no_match %r{<perishable-token}, @xml
    end
    
    should "not serialize the persistence token" do
      assert_no_match %r{<persistence-token}, @xml
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
  
  context "#followers method" do
    fixtures :users
    should "return all the followers of the user but not the user himself" do
      assert users(:crossblaim).followers.include?( users(:akira) )
      assert users(:crossblaim).followers.include?( users(:dmitry) )
      assert !users(:crossblaim).followers.include?( users(:crossblaim) )
    end
  end
  
  context "inviting a user who does not have already an invitation" do
    fixtures :users, :conversations
    setup do
      @user = users(:dmitry)
      @convo = conversations(:crossblaim_test_public_convo)
      @invitee = users(:crossblaim)
      UserMailer.stubs(:deliver_public_invite_instructions).with(any_parameters).returns(true)
      UserMailer.stubs(:deliver_private_invite_instructions).with(any_parameters).returns(true)
    end

    should "have a public invite if the convo is public" do
      @user.invite(@convo, @invitee)
      @invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @convo) #eghh
      assert @invite.present?
      assert @invite.public?
    end
    
    should "have a private invite if the convo is private" do
      @convo = conversations(:crossblaim_test_private_convo)
      @user.invite(@convo, @invitee)
      @invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @convo) #eghh
      assert @invite.present?
      assert @invite.private?
    end
  end

  context "inviting a user who already have an invitation" do
    fixtures :users, :conversations
    setup do
      @user = users(:dmitry)
      @public_convo = conversations(:crossblaim_test_public_convo)
      @private_convo = conversations(:crossblaim_test_private_convo)
      @invitee = users(:crossblaim)
      UserMailer.stubs(:deliver_public_invite_instructions).with(any_parameters).returns(true)
      UserMailer.stubs(:deliver_private_invite_instructions).with(any_parameters).returns(true)
      @user.invite(@public_convo, @invitee)
      @user.invite(@private_convo, @invitee)
    end

    should "not be invited again if the convo is public and the old invite is public" do
      @old_invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @public_convo)
      @user.invite(@public_convo, @invitee)
      @invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @public_convo)
      assert_equal @old_invite, @invite
    end
    
    should "not be invited again if the convo is private and the old invite is private" do
      @old_invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @private_convo)
      @user.invite(@private_convo, @invitee)
      @invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @private_convo)
      assert_equal @old_invite, @invite
    end
    
    should "get a new invite if the convo is private and the old invite is public" do
      @old_invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @public_convo)
      @public_convo.private = true
      @public_convo.save
      @user.invite(@public_convo, @invitee) # @public_convo is now private
      @invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @public_convo)
      assert @invite.private?
      assert_not_equal @old_invite, @invite
      # should have only one invite
      @invites = Invite.all(:conditions => {:user_id => @user.id, :requestor_id => @invitee.id, :conversation_id => @public_convo.id})
      assert_equal 1, @invites.length
    end
    
    should "get a new invite if the convo is public and the old invite is private" do
      @old_invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @private_convo)
      @private_convo.private = false
      @private_convo.save
      @user.invite(@private_convo, @invitee) # @private_convo is now public
      @invite = Invite.find_by_user_id_and_requestor_id_and_conversation_id(@user, @invitee, @private_convo)
      assert @invite.public?
      assert_not_equal @old_invite, @invite
      # should have only one invite
      @invites = Invite.all(:conditions => {:user_id => @user.id, :requestor_id => @invitee.id, :conversation_id => @private_convo.id})
      assert_equal 1, @invites.length
    end
    
  end
  
end
