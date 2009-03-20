require File.dirname(__FILE__) + '/../test_helper'

class FixturesTest < ActiveSupport::TestCase
  fixtures :users, :conversations, :subscriptions
  
  test "fixtures should be correct" do
    assert_equal 3, User.all.length
    assert_equal 4, Conversation.all.length
    # personal convos
    assert conversations(:crossblaim_personal_convo).personal?
    assert_equal conversations(:crossblaim_personal_convo), users(:crossblaim).personal_conversation
    # non personal public writeable convos
    assert !conversations(:crossblaim_test_public_convo).personal?
    assert !conversations(:crossblaim_test_public_convo).read_only?
    assert !conversations(:crossblaim_test_public_convo).private?
    # followers
    assert_equal [users(:akira), users(:dmitry)], users(:crossblaim).followers
    # friends
    assert_equal [users(:akira)], users(:crossblaim).friends
    assert_equal [users(:crossblaim)], users(:dmitry).friends
    assert_equal [users(:crossblaim), users(:dmitry)], users(:akira).friends
    # followers_convos
    assert_equal 2, users(:crossblaim).followers_convos.length
    # users
    assert users(:crossblaim).active?
  end

end
