# handle asynchronous mailing
#----------------------------------------------------------------------------
class MailerWorker < Workling::Base
  
  def deliver_private_invite_instructions(options)
    user = User.find(options[:user_id])
    invite = Invite.find(options[:invite_id])
    user.deliver_private_invite_instructions!(invite)
  end
  
  def deliver_public_invite_instructions(options)
    user = User.find(options[:user_id])
    invite = Invite.find(options[:invite_id])
    user.deliver_public_invite_instructions!(invite)
  end
  
end