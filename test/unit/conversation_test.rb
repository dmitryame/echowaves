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
      
      assert_equal @conversation.users.size, 4 # it has to be one more user, the one who created the convo
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
    
    should_have_many :abuse_reports
    should_belong_to :abuse_report

    should_belong_to :parent_message #parent message it was spawned from
    should_have_index :parent_message_id
    
    should_belong_to :user
    should_have_index :user_id
    
    should "be valid if honeypot field is blank" do
      assert @conversation.valid?
    end
    
    should "not be valid if honeypot field is not blank" do
      @conversation.something = "spam"
      assert !@conversation.valid?
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

  context "Conversation#add_personal method" do
    setup do
      @user = Factory.create( :user )
      @conversation = Conversation.add_personal( @user )
      @user.reload
    end

    should "create a new personal conversation for the user" do
      assert_equal 1, @user.conversations.size  
      assert @conversation.description.include?("This is a personal conversation for #{@user.name}")
    end

    should "create a subscription to the new personal conversation for the user" do
      assert_equal 1, @user.subscriptions.size
      assert_equal @conversation, @user.subscriptions.first.conversation
    end

    should "respond to #personal?" do
      assert @conversation.personal?
    end
  end

  context "A regular conversation instance" do
    setup do
      @user = Factory.create( :user )
      @conversation = Factory.create( :conversation, :user => @user, :name => 'Convo name', :description => 'convo description' )
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
      assert_equal false, @conversation.followed?( @user )

      @conversation.add_subscription( @user )
      @conversation.reload

      assert_equal 2, @conversation.subscriptions.size
      assert @conversation.followed?( @user )
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

  context "Abuse reports" do
    setup do
      @owner = Factory.create( :user )
      @conversation = Factory.create( :conversation, :user => @owner )
    end

    should "create a new abuse report" do
      assert_equal 0, @conversation.abuse_reports.size
      @conversation.report_abuse( Factory.create( :user ) )
      assert_equal 1, @conversation.abuse_reports.size
    end

    should "only allow one abuse report per user" do
      user = Factory.create( :user )
      @conversation.report_abuse( user )
      assert_equal 1, @conversation.abuse_reports.size
      @conversation.report_abuse( user )
      assert_equal 1, @conversation.abuse_reports.size
    end

    should "check against abuse report limit" do
      assert_equal false, @conversation.over_abuse_reports_limit?
      assert @conversation.published?
      (1..CONVERSATION_ABUSE_THRESHOLD).each do |num|
        @conversation.report_abuse( Factory.create( :user ) )
        assert_equal false, @conversation.over_abuse_reports_limit?
      end
      @conversation.report_abuse( Factory.create( :user ) )
      assert @conversation.over_abuse_reports_limit?
      assert_equal false, @conversation.published?
    end

    should "unpublish if conversation owner reported the abuse" do
      assert @conversation.published?
      @conversation.report_abuse( @owner )
      assert_equal false, @conversation.published?
    end
  end # context 'Abuse reports'

  context "notify of new spawn" do
    setup do
      @user = Factory.create( :user )
      @owner = Factory.create( :user )
      @conversation = Factory.create( :conversation, :user => @owner )
      @message = Factory.create( :message, :user => @user, :conversation => @conversation )
      @spawn_convo = Factory.create( :conversation, :user => @user, :parent_message_id => @message.id )
    end

    should "return a Message object" do
      notification = @spawn_convo.notify_of_new_spawn( @user )
      assert_kind_of Message, notification
      assert_match /spawned by/, notification.message
    end
  end
  
end
