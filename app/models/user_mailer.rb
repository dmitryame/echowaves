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
  
  def private_invite_instructions(user, convo_id, token)
    setup_email(user)
    @subject    += "You're invited to participate in a private conversation"
    body        :follow_conversation_url => follow_with_token_conversation_url(convo_id, :token => token)
  end
  
protected
  
  def setup_email(user)
    default_url_options[:host] = HOST[7..-1]
    @recipients  = "#{user.email}"
    @bcc         = "dmitry@rootlocusinc.com" #email monitoring log, do not erase
    @from        = "support@echowaves.com"
    @subject     = "[echowaves.com] "
    @sent_on     = Time.now
    @body[:user] = user
  end
  
end
