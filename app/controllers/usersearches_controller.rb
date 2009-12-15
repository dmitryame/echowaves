class UsersearchesController < ApplicationController
  def ssl_required?
    true unless Rails.env.development?
  end
  
  def show
    if params.include?(:user_q)
      create
      render :create
    else
      new
      render :new
    end
  end
  
  def new
  end
  
  def create
    @users = User.search(
      params[:user_q],
      :with => { :activated => false } ,
      :page => (params[:page] || 1),
      :per_page => 10,
      :order => 'created_at DESC'
    )
  end
  
end
