# == Schema Info
# Schema version: 20090906125449
#
# Table name: conversations
#
#  id                  :integer(4)      not null, primary key
#  parent_message_id   :integer(4)
#  user_id             :integer(4)
#  delta               :boolean(1)
#  messages_count      :integer(4)      default(0)
#  name                :string(255)
#  private             :boolean(1)
#  read_only           :boolean(1)
#  something           :string(255)     default("")
#  subscriptions_count :integer(4)      default(0)
#  uuid                :string(255)
#  created_at          :datetime
#  posted_at           :datetime
#  updated_at          :datetime

require File.dirname(__FILE__) + '/../test_helper'

class ConversationTest < ActiveSupport::TestCase

  context "Conversation named scopes" do
    fixtures :users, :conversations, :subscriptions

    should "find convos no owned by a concrete user" do
      @no_from_crossblaim = Conversation.no_owned_by(users(:crossblaim).id)
      @no_from_dmitry = Conversation.no_owned_by(users(:dmitry).id)
      assert_equal 2, @no_from_crossblaim.size
      assert_equal 4, @no_from_dmitry.size
      assert @no_from_crossblaim.include?(conversations(:dmitry_convo))
      assert @no_from_crossblaim.include?(conversations(:akira_convo))
      assert @no_from_dmitry.include?(conversations(:crossblaim_convo))
      assert @no_from_dmitry.include?(conversations(:akira_convo))
      assert @no_from_dmitry.include?(conversations(:crossblaim_test_public_convo))
    end
  end

  context "A Conversation instance" do
    setup do
      @conversation = Factory.create(:conversation)
    end
    subject { @conversation }

    should_validate_presence_of :uuid

    should_have_db_index :name
    should_have_db_index :created_at

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

      assert_equal 4, @conversation.users.size # it has to be one more user, the one who created the convo
    end

    # FIXME: could not get it to work :(
    # should "follow/unfollow" do
    #   conversation = Factory.create(:conversation)
    #
    #   user1 = Factory.create(:user, :login => "user10111")
    #   user2 = Factory.create(:user, :login => "user20111")
    #   user3 = Factory.create(:user, :login => "user30111")
    #
    #   user1.follow(conversation)
    #   user2.follow(conversation)
    #   user3.follow(conversation)
    #
    #   puts "subscriptions: " + conversation.subscriptions.size.to_s
    #   assert_equal conversation.subscriptions.length, 4 # it has to be one more user, the one who created the convo
    #
    #   user1.unfollow(conversation)
    #   user2.unfollow(conversation)
    #   user3.unfollow(conversation)
    #
    #   puts "subscriptions: " + conversation.subscriptions.size.to_s
    #   assert_equal conversation.subscriptions.length, 1 # it has to be one more user, the one who created the convo
    #
    # end

    should_have_many :subscriptions
    should_have_many :users, :through => :subscriptions
    should_have_many :recent_followers, :through => :subscriptions

    should_belong_to :parent_message #parent message it was spawned from
    should_have_db_index :parent_message_id

    should_belong_to :user
    should_have_db_index :user_id

    should "be valid if honeypot field is blank" do
      assert @conversation.valid?
    end

    should "not be valid if honeypot field is not blank" do
      @conversation.something = "spam"
      assert !@conversation.valid?
      @conversation.something = " "
      assert !@conversation.valid?
    end
  end




  context "A private conversation" do
    setup do
      @owner = Factory.create(:user, :login => "user1")
      @conversation = Factory.create(:conversation, :user => @owner)
      @follower = Factory.create(:user, :login => "user2")
      @follower.follow(@conversation)
      @conversation.update_attributes(:private => true)
      @no_follower = Factory.create(:user, :login => "user3")
    end

    should "be writable by the owner" do
      assert @conversation.writable_by?(@owner)
    end

    should "not be writable by the users what are not followers of this convo" do
      assert !@conversation.writable_by?(@no_follower)
    end

    should "be writable by the users what are following this convo" do
      assert @conversation.writable_by?(@follower)
    end

    should "be readable by the owner" do
      assert @conversation.readable_by?(@owner)
    end

    should "not be readable by the users what are not followers of this convo" do
      assert !@conversation.readable_by?(@no_follower)
    end

    should "be readable by the users what are following this convo" do
      assert @conversation.readable_by?(@follower)
    end

    should "respond to #private? positively" do
      assert @conversation.private?
    end

    should "respond to #public? negatively" do
      assert !@conversation.public?
    end
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

    should "become writable on read only status toggle" do
      @conversation.toggle_read_only_status
      assert !@conversation.read_only?
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

    should "become read only on read only status toggle" do
      @conversation.toggle_read_only_status
      assert @conversation.read_only?
    end
  end

  context "A visit to a conversation" do
    setup do
      @conversation = Factory.create(:conversation)
      @user = Factory.create(:user, :login => 'user1')
    end

    should "create a new ConversationVisit on a users first visit" do
      assert_equal 0, ConversationVisit.all.length
      @conversation.add_visit(@user)
      assert_equal 1, ConversationVisit.all.length
    end

    should "update the existing ConversationVisit record on repeat visit" do
      @cv = Factory.create(:conversation_visit, :conversation => @conversation, :user => @user)
      pre_size = ConversationVisit.all.length
      @conversation.add_visit(@user)
      assert_equal pre_size, ConversationVisit.all.length
    end
  end

  context "A regular conversation instance" do
    setup do
      @user = Factory.create( :user )
      @conversation = Factory.create( :conversation, :user => @user, :name => 'Convo name' )
    end

    should "respond to #owner" do
      assert_equal @user, @conversation.owner
    end

    should "respond false to #spawned?" do
      assert_equal false, @conversation.spawned?
    end
  end

  context "A spawned conversation" do
    setup do
      @spawned = Factory.create( :conversation, :parent_message_id => '123' )
    end

    should "respond to #spawned? positively" do
      assert @spawned.spawned?
    end
  end

  context "Subscription management" do
    setup do
      @user = Factory.create( :user )
      @conversation = Factory.create( :conversation )
      @conversation.reload
    end

    should "add a new user subscription" do
      assert_equal 1, @conversation.subscriptions.size # convo owner is subscribed by default
      assert_equal false, @conversation.followed_by?( @user )

      @conversation.add_subscription( @user )
      @conversation.reload

      assert_equal 2, @conversation.subscriptions.size
      assert @conversation.followed_by?( @user )
    end

    should "remove a user subscription" do
      @conversation.add_subscription( @user )
      @conversation.reload
      assert_equal 2, @conversation.subscriptions.size

      @conversation.remove_subscription( @user )
      @conversation.reload
      assert_equal 1, @conversation.subscriptions.size

      @conversation.subscriptions.reload
      @conversation.remove_subscription( @user )
      @conversation.reload
      assert_equal 1, @conversation.subscriptions.size
    end
  end

end
