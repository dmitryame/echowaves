class UsersController < ApplicationController
  
  before_filter :login_required, :except => [:index, :show, :auto_complete_for_user_name, :complete_name, :signup, :new, :create, :activate, :forgot_password, :reset_password]
  after_filter :store_location, :only => [:index, :show]  
  
  auto_complete_for :user, :name

  def complete_name
    @user = User.find_by_name(params[:id])
    redirect_to user_path(@user)
  end
    
  # GET /conversations
  # GET /conversations.xml
  def index
    @users = User.active.paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.atom
      format.xml  { render :xml => @users }
    end
  end

  # GET /clients/1
  # GET /clients/1.xml
  def show
    @user = User.find(params[:id])

    @tag_counts = @user.all_convos_tag_counts
    
    respond_to do |format|
      format.html # show.html.erb
      format.atom
      format.xml  { render :xml => @user }
    end
  end
  
  def tagged_convos
    @user = User.find(params[:id])

    @tag = params[:tag]
    
    @tag_counts = @user.all_convos_tag_counts
    
    @convos = @user.convos_by_tag(@tag)

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
    @user.login = params[:user][:login]
    @user.name=@user.login
    success = @user && @user.save
    if success && @user.errors.empty?
      if(SHOW_ACTIVATION_LINK)
        flash[:error] = "<a href='/activate/#{@user.activation_code}'>#{t("ui.click_to_activate")}</a>" # it's really a notice, but just to attract an attention, since errors are output in red
      else
        flash[:notice] = t("ui.thanks_for_signup")
      end
      
      redirect_to home_path
    else
      flash[:error]  = t("ui.signup_error")
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @personal_conversation = @user.personal_conversation
    params[:user].delete(:login)
    if @user.update_attributes(params[:user]) && @personal_conversation.update_attributes(params[:conversation])
      flash[:notice] = t("users.profile_updated")
      redirect_to user_path(current_user)
    else
      render :action => :edit
    end
  end
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = t("users.signup_complete")
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
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
      if(SHOW_ACTIVATION_LINK)
        flash[:error] = "<a href='#{HOST}/reset_password/#{@user.password_reset_code}'>Click here to reset</a>" #want this notice it red, that's why it's error
      else 
        flash[:notice] = "A password reset link has been sent to your email address" 
      end
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

  def update_news
  end

  #
  # serve up custom style overrides
  def styles
    @user = User.find(session[:user_id])
    respond_to do |format|
      format.html { render :text => "/* html?! */" }
      # format.css  { render :text => "/* CSS! */div#messages p {font-size: 1em;line-height:1.2em;}div#messages {width: 100%;}div.message p.messagemeta .date {font-size: .7em;line-height:1em;white-space:nowrap;}div.message p.messagemeta{float:left;margin-left: -4px;margin-right:5px;}p.messagemeta img.avatar{height: 20px;}" }
      format.css  { render :text => "/* CSS! */" }
    end
  end
  
end
