class StompWorker < Workling::Base
  
  def send_to_msg_broker(options)
    msg = Message.find(options[:message_id])
    msg.send_to_msg_broker
  end

end