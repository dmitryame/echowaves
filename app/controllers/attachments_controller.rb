class AttachmentsController < ApplicationController

  before_filter :find_message_and_check_read_access
  def ssl_required? 
    true if USE_SSL
  end

  def show
    attachment_path =  @message.attachment.path
    if @message.has_image? && params[:style].present? && (['thumb','big','small'].include? params[:style])
      attachment_path.sub!('original', params[:style])
    end
    if USE_X_ACCEL_REDIRECT # nginx
      head(:x_accel_redirect => attachment_path.sub(RAILS_ROOT,''),
         :content_type => @message.attachment_content_type,
         :content_disposition => "inline")
    else # apache or others
      send_file  attachment_path, :type => @message.attachment_content_type, :disposition => 'inline', :x_sendfile => USE_X_SENDFILE
    end
  end

private

  def find_message_and_check_read_access
    @message = Rails.cache.fetch('message_'+params[:id], :expires_in => 24.hours) {Message.published.find(params[:id])}
    unless (logged_in? && @message.conversation.readable_by?(current_user)) || !@message.conversation.private?
      flash[:error] = "Sorry, this attachment is unavailable."
      redirect_to root_path
      return
    end
  end

end
