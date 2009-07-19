# handle asynchronous mailing
#----------------------------------------------------------------------------
class MailerWorker < Workling::Base
  
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
  
  def deliver_email_invite(options)
    email = options[:email]
    invite = Invite.find(options[:invite_id])
    UserMailer.deliver_email_invite(email, invite)
  end
  
end