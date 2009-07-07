class AttachmentsController < ApplicationController
  before_filter :find_message_and_check_read_access
  def show
    send_file @message.attachment.path, :type => @message.attachment_content_type, :disposition => 'inline', :x_sendfile => USE_X_SENDFILE
  end
  
  private
  
  def find_message_and_check_read_access
    @message = Message.published.find(params[:id])
    unless (logged_in? && @message.conversation.readable_by?(current_user)) || !@message.conversation.private?
      flash[:error] = "Sorry, this attachment is unavailable."
      redirect_to home_path
      return
    end
  end
  
end
