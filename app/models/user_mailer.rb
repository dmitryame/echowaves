class UserMailer < ActionMailer::Base
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "#{HOST}/activate/#{user.perishable_token}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{HOST}"
  end
  
  def password_reset_instructions(user)
    setup_email(user)
    @subject    += "Password Reset Instructions"
    body        :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
  
  def private_invite_instructions(user, convo_id, convo_name, invitor, token)
    @user = invitor    
    setup_email(user)
    @subject    += "You're invited to participate in a private conversation"
    body        :follow_conversation_url => follow_with_token_conversation_url(convo_id, :token => token), :convo_name => convo_name
  end

  def public_invite_instructions(user, convo_id, convo_name, invitor)
    @user = invitor
    setup_email(user)
    @subject    += "You're invited to participate in a conversation"
    body        :follow_conversation_url => follow_with_token_conversation_url(convo_id, :token => nil), :convo_name => convo_name
  end

  def email_invite(email, invite)
    @user = invite.requestor    
    default_url_options[:host] = HOST[7..-1]
    @recipients  = "#{email}"
    @bcc         = BCC # email monitoring log, do not erase
    @from        = FROM
    @subject     = SUBJECT
    @sent_on     = Time.now
    @subject    += "You're invited to participate in a conversation"
    body        :follow_conversation_url => follow_email_with_token_conversation_url(invite.conversation.id, :token => invite.token), :convo_name => invite.conversation.name        
  end
  
protected
  
  def setup_email(user)
    default_url_options[:host] = HOST[7..-1]
    @recipients  = "#{user.email}"
    @bcc         = BCC # email monitoring log, do not erase
    @from        = FROM
    @subject     = SUBJECT
    @sent_on     = Time.now
    @body[:user] = user
  end
  
end
