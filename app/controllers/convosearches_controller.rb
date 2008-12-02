class ConvosearchesController < ApplicationController
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
    @conversations = Conversation.search(params[:q], :page => (params[:page] || 1), :per_page => 10, :order => 'created_at DESC')
  end
end
