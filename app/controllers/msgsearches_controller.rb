class MsgsearchesController < ApplicationController
  def show
    if params.include?(:q)
      create
      render :action => "create"
    else
      new
      render :action => "new"
    end
  end
  
  def new
  end
  
  def create
    @messages = Message.search(params[:q], :page => (params[:page] || 1), :per_page => 10)
  end
end
