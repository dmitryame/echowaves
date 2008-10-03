class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  
  def edit
     if request.post?
       @user.update_attributes(params[:user])
     else
       @user = User.find(session[:user_id])    
     end
   end

   # Change password action  
   def change_password
     return unless request.post?
     if User.authenticate(current_user.login, params[:old_password])
       if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
         current_user.password_confirmation = params[:password_confirmation]
         current_user.password = params[:password]        
         if current_user.save
           flash[:notice] = "Password successfully updated."
           redirect_to root_path #profile_url(current_user.login)
         else
           flash[:error] = "An error occured, your password was not changed."
           render :action => 'edit'
         end
       else
         flash[:error] = "New password does not match the password confirmation."
         @old_password = params[:old_password]
         render :action => 'edit'      
       end
     else
       flash[:error] = "Your old password is incorrect."
       render :action => 'edit'
     end 
   end

   #
   #gain email address
   def forgot_password
     return unless request.post?
     if @user = User.find_by_email(params[:user][:email])
       @user.forgot_password
       @user.save
       flash[:notice] = "A password reset link has been sent to your email address" 
       redirect_to :controller   => "sessions", :action => "new"
     else
       flash[:error] = "Could not find a user with that email address" 
     end
   end

   #
   #reset password
   def reset_password
     @user = User.find_by_password_reset_code(params[:id])
     #raise if @user.nil?

     return if @user unless params[:user]

     if ((params[:user][:password]  == params[:user][:password_confirmation]) && !params[:user][:password_confirmation].blank?)
       #if (params[:user][:password]  params[:user][:password_confirmation])
       self.current_user = @user #for the next two lines to work
       current_user.password_confirmation = params[:user][:password_confirmation]
       current_user.password = params[:user][:password]
       @user.reset_password
       flash[:notice] = current_user.save ? "Password reset" : "Password not reset"
       redirect_back_or_default('/')
     else
       flash[:error] = "Password mismatch"
     end  

   rescue
     logger.error "Invalid Reset Code entered" 
     flash[:error] = "That is an invalid password reset code. Please check your code and try again." 
     redirect_back_or_default('/')
   end



   def update
     if @user.update_attributes(params[:user])
         flash[:notice] = "User updated"
         redirect_to user_path(current_user)
       else
         render :action => :edit
       end
   end
  
end
