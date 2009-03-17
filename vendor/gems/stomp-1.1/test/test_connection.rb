require File.join(File.dirname(__FILE__), 'test_helper.rb')

class TestStomp < Test::Unit::TestCase

  def setup
    @conn = Stomp::Connection.open("test", "user", "localhost", 61613)
  end

  def teardown
    @conn.disconnect
  end

  def make_destination
    "/queue/test/ruby/stomp/" + name()
  end

  def _test_transaction
    @conn.subscribe make_destination

    # Drain the destination.
    sleep 0.01 while
    sleep 0.01 while @conn.poll!=nil

    @conn.begin "tx1"
    @conn.send make_destination, "txn message", 'transaction' => "tx1"

    @conn.send make_destination, "first message"

    sleep 0.01
    msg = @conn.receive
    assert_equal "first message", msg.body

    @conn.commit "tx1"
    msg = @conn.receive
    assert_equal "txn message", msg.body
  end

  def test_connection_exists
    assert_not_nil @conn
  end

  def test_explicit_receive
    @conn.subscribe make_destination
    @conn.send make_destination, "test_stomp#test_explicit_receive"
    msg = @conn.receive
    assert_equal "test_stomp#test_explicit_receive", msg.body
  end

  def test_receipt
    @conn.subscribe make_destination, :receipt => "abc"
    msg = @conn.receive
    assert_equal "abc", msg.headers['receipt-id']
  end

  def test_client_ack_with_symbol
    @conn.subscribe make_destination, :ack => :client
    @conn.send make_destination, "test_stomp#test_client_ack_with_symbol"
    msg = @conn.receive
    @conn.ack msg.headers['message-id']
  end

  def test_embedded_null
    @conn.subscribe make_destination
    @conn.send make_destination, "a\0"
    msg = @conn.receive
    assert_equal "a\0" , msg.body
  end

  def test_connection_open?
    assert_equal true , @conn.open?
    @conn.disconnect
    assert_equal false, @conn.open?
  end

  def test_connection_closed?
    assert_equal false, @conn.closed?
    @conn.disconnect
    assert_equal true, @conn.closed?
  end

  def test_response_is_instance_of_message_class
    @conn.subscribe make_destination
    @conn.send make_destination, "a\0"
    msg = @conn.receive
    assert_instance_of Stomp::Message , msg
  end

  def test_message_to_s
    @conn.subscribe make_destination
    @conn.send make_destination, "a\0"
    msg = @conn.receive
    assert_match /^<Stomp::Message headers=/ , msg.to_s
  end

end
