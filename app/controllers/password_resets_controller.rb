class PasswordResetsController < ApplicationController
  
  layout "users"
  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  
  def edit
    render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated"
      redirect_to "/"
    else
      render :action => :edit
    end
  end
    
  def new
    render
  end
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      if(SHOW_ACTIVATION_LINK)
        flash[:error] = "<a href=\"#{HOST}/password_resets/#{@user.perishable_token}/edit\">Click here to reset your password</a>" #want this notice it red, that's why it's error
      else 
        flash[:notice] = "Instructions to reset your password have been emailed to you. " +
          "Please check your email."
      end
      redirect_to "/"
    else
      flash[:notice] = "No user was found with that email address"
      render :action => :new
    end
  end
  
private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id], 0)
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. " +
        "If you are having issues try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to "/"
    end
  end
  
end