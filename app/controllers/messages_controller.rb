class MessagesController < ApplicationController
  def ssl_required?
    true if USE_SSL
  end

  before_filter :login_or_oauth_required, :except => [:index, :show, :get_more_messages, :export ]
  before_filter :find_conversation, :except => [ :send_data, :auto_complete_for_tag_name]
  before_filter :check_write_access, :only => [ :create, :upload_attachment ]
  before_filter :check_read_access, :except => [ :upload_attachment, :report ]

  auto_complete_for :tag, :name

  def index
    case params[:action]
    when 'images'
      @messages = @conversation.messages.with_image.published.find(:all, :limit => Message::PER_PAGE, :order => 'id DESC').reverse
    when 'files'
      @messages = @conversation.messages.with_file.published.find(:all, :limit => Message::PER_PAGE, :order => 'id DESC').reverse
    else
      @messages = @conversation.messages.published.find(:all, :limit => Message::PER_PAGE, :order => 'id DESC').reverse
    end
    respond_to do |format|
      format.html do
        headers["Status"] = "301 Moved Permanently"
        redirect_to conversation_path(@conversation)
      end
      format.json do
        if logged_in?
          subscription = current_user.subscriptions.find_by_conversation_id(@conversation.id)
          current_user.conversation_visit_update(@conversation) if logged_in?
          @last_message_id = subscription.last_message_id if (subscription && subscription.new_messages_count > 0)
        end
        data = group_and_json( @messages )
        render :text => {:message_groups => data, :last_message_id => @last_message_id}.to_json
      end
      format.xml do
        if logged_in?
          subscription = current_user.subscriptions.find_by_conversation_id(@conversation.id)
          current_user.conversation_visit_update(@conversation) if logged_in?
          @last_message_id = subscription.last_message_id if (subscription && subscription.new_messages_count > 0)
        end
        render :xml => @messages.to_xml(:include => [:user])
      end
    end
  end

  alias_method :images, :index
  alias_method :files, :index

  def export
    @messages = @conversation.messages.published.find(:all, :include => [:user], :order => 'id DESC').reverse
    render :layout => 'export'
  end

  #TODO: get_more_messages, get_more_messages_on_top, get_more_messages_on_bottom need to be refactored into something more generic
  def get_more_messages
    @messages = @conversation.messages_before(params[:before]).reverse
    @has_more_messages = @conversation.has_messages_before?(@messages.first)
    @last_message_id = @messages.first.id
  end

  def get_more_messages_on_top
    @messages = @conversation.messages_before(params[:before]).reverse
    @has_more_messages_on_top = @conversation.has_messages_before?(@messages.first)
  end

  def get_more_messages_on_bottom
    @messages = @conversation.messages_after(params[:after]).reverse
    @has_more_messages_on_bottom = @conversation.has_messages_after?(@messages.last)
  end

  def show
    @message = Message.published.find(params[:id])
    @messages = Array[@message]

    @has_more_messages_on_top    = @conversation.has_messages_before?(@message)
    @has_more_messages_on_bottom = @conversation.has_messages_after?(@message)

    respond_to do |format|
      format.html { render :layout => "single_message" }
      format.xml  { render :xml => @message }
    end
  end

  def create
    @message = @conversation.messages.new(params[:message])
    respond_to do |format|
      if current_user.messages << @message
        cache_message(@message)
        format.html { redirect_to(conversation_path(@conversation)) }
        format.xml {
          @message.send_to_msg_broker
          render :xml => @message, :status => :created, :location => conversation_message_url(@message.conversation_id, @message)
        }
        format.js {
          # send a message for everyone else to pick it up
          @message.send_to_msg_broker
          render :nothing => true
        }
      else
        format.html { render :nothing => true }
        format.xml { render :xml => @message.errors, :status => :unprocessable_entity }
        format.js { render :nothing => true }
      end
    end
  end

  def upload_attachment
    render( :nothing => true ) and return if params[:message][:attachment].blank?

    @message = current_user.messages.new(params[:message])
    @message.message = @message.attachment_file_name if @message.message.blank?

    if @conversation.messages << @message
      # send a stomp message for everyone else to pick it up
      @message.send_to_msg_broker
    end
    # FIXME: this not work yet, because we are calling this action from an iframe,
    # and the RJS can't access the document.
    # We need something like respond_to_parent plugin, but this plugin don't work with safari 3
    # right now.
    # This will be useful for fix issue #1, and for reset the forms AFTER upload an
    # attachment
    #
    # render :action => 'upload_attachment.js.rjs'

    render :nothing => true
  end

  def report
    message = @conversation.messages.find(params[:id])
    message.report_abuse(current_user)
    render :nothing => true
  end

private

  def find_conversation
    @conversation = Conversation.find( params[:conversation_id] )
  end

  def check_write_access
    unless @conversation.writable_by?(current_user)
      flash[:error] = t("conversations.not_allowed_to_write_warning")
      redirect_to conversation_path(@conversation)
    end
  end

  def check_read_access
    unless @conversation.readable_by?(current_user) || !@conversation.private?
      flash[:error] = t("errors.sorry_this_is_a_private_convo")
      redirect_to conversations_path
    end
  end

  def group_and_json(messages)
    data = []
    messages.group_by(&:date).each do |date, grouped_messages|
      group = { :date => date }
      group.merge!({ :messages => grouped_messages.map { |message| cache_message(message); message.data_for_templates } })

      data << group
    end
    return data
  end

  def cache_message(message)
    Rails.cache.write("message_#{message.id}", message, :unless_exist => true, :expires_in => 24.hours) unless message.attachment_type == 'unknow'
  end
end
