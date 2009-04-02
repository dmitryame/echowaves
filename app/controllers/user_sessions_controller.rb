class UserSessionsController < ApplicationController

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
    
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default user_path( @user_session.user )
      flash[:notice] = t("users.logged_in_sucesfully")
    else
      note_failed_signin
      render :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = t("users.logged_out")
    redirect_back_or_default('/')
  end

protected
  
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = t("users.could_not_login_as", :login => params[:user_session][:login])
    logger.warn "Failed login for '#{params[:user_session][:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
end
