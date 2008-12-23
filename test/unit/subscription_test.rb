require File.dirname(__FILE__) + '/../test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  context "A Subscription instance" do    
     setup do
       @subscription = Factory(:subscription)
     end
     
     should_belong_to :user
     should_belong_to :conversation
     
     should_have_indices :user_id, :conversation_id, :activated_at
     should_require_attributes :user_id, :conversation_id
  end

  context "marking as read" do
    setup do
      @user = Factory.create( :user )
      @convo = Factory.create( :conversation )
      @subscription = Factory.create( :subscription, :user => @user, :conversation => @convo )
    end

    should "do nothing if there are no messages" do
      assert_equal 0, @subscription.last_message_id
      @subscription.mark_read
      assert_equal 0, @subscription.last_message_id
    end

    should "update last_message_id if there are messages" do
      assert_equal 0, @subscription.last_message_id
      msg1 = Factory.create( :message, :conversation => @convo, :user => @user)
      @subscription.mark_read
      assert_equal msg1.id, @subscription.last_message_id
      msg2 = Factory.create( :message, :conversation => @convo, :user => @user)
      msg3 = Factory.create( :message, :conversation => @convo, :user => @user)
      @subscription.reload
      @subscription.mark_read
      assert_equal msg3.id, @subscription.last_message_id
    end
  end

  context "activating a subscription" do
    setup do
      @user = Factory.create( :user )
      @convo = Factory.create( :conversation )
      @subscription = Factory.create( :subscription, :user => @user, :conversation => @convo )
      @msg1 = Factory.create( :message, :conversation => @convo, :user => @user)
    end

    should "update activated_at timestamp" do
      assert_nil @subscription.activated_at
      @subscription.activate
      assert_not_nil @subscription.activated_at
    end

    should "update last_message_id" do
      assert_equal 0, @subscription.last_message_id
      @subscription.activate
      assert_equal @msg1.id, @subscription.last_message_id
    end
  end

  context "new messages counter" do
    setup do
      @user = Factory.create( :user )
      @convo = Factory.create( :conversation )
      @subscription = Factory.create( :subscription, :user => @user, :conversation => @convo )
    end

    should "return 0 if no messages at all" do
      assert_equal 0, @subscription.new_messages_count
    end

    should "return 0 if no new message" do
      assert_equal 0, @subscription.new_messages_count
      msg1 = Factory.create( :message, :conversation => @convo )
      @subscription.mark_read
      assert_equal 0, @subscription.new_messages_count
    end 

    should "return count if new messages exist" do
      assert_equal 0, @subscription.new_messages_count
      msg1 = Factory.create( :message, :conversation => @convo )
      @subscription.mark_read
      (1..5).each { Factory.create( :message, :conversation => @convo ) }
      assert_equal 5, @subscription.new_messages_count
    end
  end
end
