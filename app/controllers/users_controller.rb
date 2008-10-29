class UsersController < ApplicationController
  before_filter :login_required, :except => [:signup, :new, :create, :activate, :forgot_password, :reset_password]

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  auto_complete_for :user, :name

  def complete_name
    @user = User.find_by_name(params[:id])
    redirect_to user_path(@user)
  end
  
  
  # GET /conversations
  # GET /conversations.xml
  def index
    @users = User.paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /clients/1
  # GET /clients/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.name=@user.login
    success = @user && @user.save
    if success && @user.errors.empty?
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
      redirect_to home_path
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
     raise if @user.nil?

     return if @user unless params[:user]

     if ((params[:user][:password]  == params[:user][:password_confirmation]) && !params[:user][:password_confirmation].blank?)
       #if (params[:user][:password]  params[:user][:password_confirmation])
       @user.password_confirmation = params[:user][:password_confirmation]
       @user.password = params[:user][:password]
       self.current_user = @user 
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

   
   #
   # serve up custom style overrides
   def styles
     @user = User.find(session[:user_id])

     respond_to do |format|
       format.html { render :text => "/* html?! */" }
#       format.css  { render :text => "/* CSS! */div#messages p {font-size: 1em;line-height:1.2em;}div#messages {width: 100%;}div.message p.messagemeta .date {font-size: .7em;line-height:1em;white-space:nowrap;}div.message p.messagemeta{float:left;margin-left: -4px;margin-right:5px;}p.messagemeta img.avatar{height: 20px;}" }
       format.css  { render :text => "/* CSS! */" }
     end
   end

end
