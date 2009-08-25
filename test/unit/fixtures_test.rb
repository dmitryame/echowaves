require File.dirname(__FILE__) + '/../test_helper'

class FixturesTest < ActiveSupport::TestCase
  fixtures :users, :conversations, :subscriptions
  
  test "fixtures should be correct" do
    assert_equal 3, User.all.length
    assert_equal 5, Conversation.all.length

    # non personal public writeable convos
    assert !conversations(:crossblaim_test_public_convo).read_only?
    assert !conversations(:crossblaim_test_public_convo).private?
    # followers
    assert_equal [users(:akira), users(:dmitry)], users(:crossblaim).followers
    # friends
    assert_equal [users(:akira)], users(:crossblaim).friends
    assert_equal [], users(:dmitry).friends
    assert_equal [users(:crossblaim)], users(:akira).friends
    # users
    assert users(:crossblaim).active?
  end

end
