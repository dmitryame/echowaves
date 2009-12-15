class MsgsearchesController < ApplicationController
  ssl_required :show, :create unless Rails.env.development?
  def ssl_allowed? 
     true unless Rails.env.development?
  end
  
  def show
    if params.include?(:q)
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
    @messages = Message.search(
      params[:q],
      :with => { :abuse_report_id => '@nil@' } ,
      :page => (params[:page] || 1),
      :per_page => 10,
      :order => 'created_at DESC'
    )
  end
  
end
