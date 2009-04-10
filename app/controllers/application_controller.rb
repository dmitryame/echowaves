class ApplicationController < ActionController::Base
    
  helper_method :current_user_session, :current_user, :logged_in?
  helper :all # include all helpers, all the time
  
  filter_parameter_logging "password"

  # protect_from_forgery
  
  before_filter :set_locale
  before_filter :set_sound
  before_filter :set_timezone

  def set_locale   
    session[:locale] = params[:locale] if params[:locale]
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def set_timezone
    Time.zone = current_user.time_zone if current_user
  end
  
  def set_sound
    session[:sound] = params[:sound] if params[:sound]
  end
  
private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_user
    unless current_user
      store_location
      flash[:notice] = t("notices.you_must_be_logged_in")
      redirect_to new_user_session_url
      return false
    end
  end
  
  alias_method :login_required, :require_user
  
  def require_no_user
    if current_user
      store_location
      flash[:notice] = t("notices.you_must_be_logged_out")
      redirect_to "/"
      return false
    end
  end
  
  def verify_oauth_signature
    begin
      valid = ClientApplication.verify_request(request) do |request|
        self.current_token = ClientApplication.find_token(request.token)
        logger.info "self=#{self.class.to_s}"
        logger.info "token=#{self.current_token}"
        [(current_token.nil? ? nil : current_token.secret), (current_client_application.nil? ? nil : current_client_application.secret)]
      end
      valid
    rescue
      false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
end