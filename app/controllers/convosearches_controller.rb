class ConvosearchesController < ApplicationController
  ssl_required :show, :create unless Rails.env.development?
  
  def show
    if params.include?(:convo_q)
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
    @conversations = Conversation.search(
      params[:convo_q],
      :page => (params[:page] || 1),
      :per_page => 10,
      :order => 'created_at DESC'
    )
  end
  
end
