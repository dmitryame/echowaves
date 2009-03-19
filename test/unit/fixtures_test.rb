require File.dirname(__FILE__) + '/../test_helper'

class FixturesTest < ActiveSupport::TestCase
  fixtures :users, :conversations, :subscriptions
  
  test "fixtures should be correct" do
    assert_equal 3, User.all.length
    assert_equal 3, Conversation.all.length
    # personal convos
    assert conversations(:crossblaim_personal_convo).personal?
    assert_equal conversations(:crossblaim_personal_convo), users(:crossblaim).personal_conversation
    # followers
    assert_equal [users(:akira), users(:dmitry)], users(:crossblaim).followers
    # friends
    assert_equal [users(:akira)], users(:crossblaim).friends
    assert_equal [users(:crossblaim)], users(:dmitry).friends
    assert_equal [users(:crossblaim), users(:dmitry)], users(:akira).friends
  end

end
