class EchowavesWorker < Workling::Base

  def deliver_private_invite_instructions(options)
    user = User.find(options[:user_id])
    invite = Invite.find(options[:invite_id])
    UserMailer.deliver_private_invite_instructions(user, invite.conversation_id, invite.conversation.name, invite.requestor, invite.token)
  end

  def deliver_public_invite_instructions(options)
    user = User.find(options[:user_id])
    invite = Invite.find(options[:invite_id])
    UserMailer.deliver_public_invite_instructions(user, invite.conversation_id, invite.conversation.name, invite.requestor)
  end

  def deliver_notification_about_new_convo(options)
    user = User.find(options[:user_id])
    convo = Conversation.find(options[:convo_id])
    requestor = User.find(options[:requestor_id])
    UserMailer.deliver_notification_about_new_convo(user, convo.id, convo.name, requestor)
  end


  def deliver_email_invite(options)
    email = options[:email]
    invite = Invite.find(options[:invite_id])
    UserMailer.deliver_email_invite(email, invite)
  end

  def send_to_msg_broker(options)
    msg = Message.find(options[:message_id])
    msg.send_to_msg_broker
  end

  def invite_followers_to_new_convo(options)
    user = User.find(options[:user_id])
    convo = Conversation.find(options[:conversation_id])
    user.followers.each do |u|
      u.invite convo, user
    end
  end

  def notify_followers_about_new_convo(options)
    requestor = User.find(options[:user_id])
    requestor.followers.each do |u|
      u.deliver_notification_about_new_convo! options[:conversation_id], requestor.id
    end
  end


  def force_followers_to_follow_new_convo(options)
    user = User.find(options[:user_id])
    convo = Conversation.find(options[:conversation_id])
    user.followers.each do |u|
      u.follow convo
    end
  end

end