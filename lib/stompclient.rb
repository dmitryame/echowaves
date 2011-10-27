require 'eventmachine'

class StompClient < EM::Connection
  include EM::Protocols::Stomp

  def connection_completed
    connect
  end

  def unbind
    EventMachine::stop_event_loop
  end

  private

  def log msg
    puts msg
  end
end