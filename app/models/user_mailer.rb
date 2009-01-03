class UserMailer < ActionMailer::Base
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "#{HOST}/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "#{HOST}"
  end

  def forgot_password(user)
    setup_email(user)
    @subject    += 'You have requested to change your password'
    @body[:url]  = "#{HOST}/reset_password/#{user.password_reset_code}" 
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset.'
  end
  
protected
  
  def setup_email(user)
    @recipients  = "#{user.email}"
    @bcc         = "dmitry@rootlocusinc.com" #email monitoring log, do not erase
    @from        = "support@echowaves.com"
    @subject     = "[echowaves.com] "
    @sent_on     = Time.now
    @body[:user] = user
  end
  
end
