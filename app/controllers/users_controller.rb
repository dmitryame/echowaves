class UsersController < ApplicationController

  before_filter :require_user, :only => [ :edit, :update, :update_news, :change_password ]
  
  auto_complete_for :user, :name

  def index
    @users = User.active.paginate :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html
      format.atom
      format.xml  { render :xml => @users }
    end
  end

  def show
    @user = User.find(params[:id])
    @conversations = @user.conversations.not_personal.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 20
    respond_to do |format|
      format.html
      format.atom
      format.xml  { render :xml => @user }
    end
  end
  
  # TODO: optimize each method as needed, or refactor
  # followers, followed_users, followed_convos
  def followers
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end
  
  def followed_users
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end
  
  def followed_convos
    @user = User.find(params[:id])
    @conversations = @user.subscribed_conversations.not_personal.no_owned_by(@user.id).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 20
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end
  
  def tagged_convos
    @user = User.find(params[:id])
    @tag = params[:tag]
    @tag_counts = @user.all_convos_tag_counts
    @convos = @user.convos_by_tag(@tag)

    respond_to do |format|
      format.html
      # format.xml  { render :text => @user.to_xml( :only => [:id, :login, :name,
      #                                                      :created_at, :conversations_count,
      #                                                      :messages_count, :subscriptions_count] ) }
    end
  end

  def new
    @user = User.new
  end
 
  def create
    @user = User.new(params[:user])
    @user.login = params[:user][:login]
    @user.name = @user.login if params[:user][:name].blank?
    @user.email              = params[:user][:email] 
    @user.email_confirmation = params[:user][:email_confirmation] 

    success = @user && @user.save
    if success && @user.errors.empty?
      if(SHOW_ACTIVATION_LINK)
        flash[:error] = "<a href='/activate/#{@user.perishable_token}'>#{t("ui.click_to_activate")}</a>" # it's really a notice, but just to attract an attention, since errors are output in red
      else
        flash[:notice] = t("ui.thanks_for_signup")
      end
      redirect_to home_path
    else
      flash[:error]  = t("ui.signup_error")
      render :new
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
      render :edit
    end
  end
  
  def activate
    user = User.find_using_perishable_token(params[:perishable_token], 0) unless params[:perishable_token].blank?
    case
    when (!params[:perishable_token].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = t("users.signup_complete")
      redirect_to '/login'
    when params[:perishable_token].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

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
          render :edit
        end
      else
        flash[:error] = "New password does not match the password confirmation."
        @old_password = params[:old_password]
        render :edit      
      end
    else
      flash[:error] = "Your old password is incorrect."
      render :edit
    end 
  end
  
  def update_news
    @conversation = Conversation.find(params[:conversation_id])
  end
  
  # TODO: can I remove this thing?
  def complete_name
    @user = User.find_by_name(params[:id])
    redirect_to user_path(@user)
  end
  
end
