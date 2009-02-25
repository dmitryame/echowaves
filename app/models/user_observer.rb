class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
    UserMailer.deliver_signup_notification(user)
  end
  
end
