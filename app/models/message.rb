# == Schema Info
# Schema version: 20090906125449
#
# Table name: messages
#
#  id                      :integer(4)      not null, primary key
#  abuse_report_id         :integer(4)
#  conversation_id         :integer(4)
#  user_id                 :integer(4)
#  attachment_content_type :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer(4)
#  attachment_height       :integer(4)
#  attachment_width        :integer(4)
#  delta                   :boolean(1)
#  message                 :text
#  message_html            :text
#  something               :string(255)     default("")
#  attachment_updated_at   :datetime
#  created_at              :datetime
#  updated_at              :datetime

class Message < ActiveRecord::Base
  
  PER_PAGE = 50
    
  auto_html_for(:message) do
    html_escape
    gist
    youtube(:width => 400, :height => 250)
    vimeo(:width => 400, :height => 250)
    google_video(:width => 400, :height => 250)
    user
    # TODO: fix rendering of image urls
    # image
    link(:target => "_blank", :rel => "nofollow")
    simple_format
  end
    
  belongs_to :conversation, :counter_cache => true 
  belongs_to :user, :counter_cache => true
  belongs_to :abuse_report # FIXME: should this really have a double association to the same model?
  
  has_many :abuse_reports # FIXME: should this really have a double association to the same model?
  has_many :conversations, # these are the conversations spawned from the message
           :foreign_key => "parent_message_id"


  has_attached_file :attachment,
    :styles => {
      :thumb => "64x64>",
      :small => "150x150>",
      :big   => "400x400>" 
    },
    :path => PAPERCLIP_PATH,
    :url  => "/attachments/:id?style=:style"
  
  after_attachment_post_process  :post_process_attachment
  
  def post_process_attachment
    if attachment.content_type.include?("image")
      self.attachment_height = Paperclip::Geometry.from_file(attachment.queued_for_write[:big].path).height.to_i  
      self.attachment_width = Paperclip::Geometry.from_file(attachment.queued_for_write[:big].path).width.to_i
    end
  end
    
  named_scope :published,  :conditions => { :abuse_report_id => nil }
  named_scope :with_file,  :conditions => [ "attachment_content_type not like ?","image%" ]
  named_scope :with_image, :conditions => [ "attachment_content_type like ?",'image%' ]
  # sphinx index
  #----------------------------------------------------------------------------
  define_index do
    indexes message
    has created_at
    has abuse_report_id
    set_property :delta => :delayed
  end
          
  validates_attachment_size :attachment, :less_than => 5.megabytes
  validates_attachment_content_type :attachment, :content_type => [ 'application/msword', 'application/pdf', 'application/x-pdf', 'application/rtf', 'text/plain', 'image/gif', 'image/jpeg', 'image/png', 'image/tiff', 'image/rgb', 'application/zip', 'application/x-gzip' ]
  validates_presence_of :user_id, :conversation_id, :message
  validates_format_of :something, :with => /^$/ # anti spam, honeypot field must be blank
    
  #----------------------------------------------------------------------------
  def published?
    self.abuse_report.nil?
  end

  #----------------------------------------------------------------------------
  def has_attachment?
    self.attachment.exists?
  end
  
  def attachment_type
    mimetype = self.attachment_content_type
    case mimetype
    when /word/;  "doc"
    when /pdf/;   "pdf"
    when /rtf/;   "rtf"
    when /text/;  "txt"
    when /zip/;   "zip"
    when /image/; "image"
    else;         "unknow"
    end
  end
  
  #----------------------------------------------------------------------------
  def has_file?
    has_attachment? and self.attachment_type != "image"
  end

  #----------------------------------------------------------------------------
  def has_image?
    has_attachment? and self.attachment_content_type.include?("image")
  end
    
  #----------------------------------------------------------------------------
  def over_abuse_reports_limit?
    self.abuse_reports.size > MESSAGE_ABUSE_THRESHOLD
  end

  # add an abuse report per user
  #----------------------------------------------------------------------------
  def report_abuse(user)
    unless abuse_report = self.abuse_reports.find_by_user_id(user.id)
      abuse_report = self.abuse_reports.create(:user => user)
    end
    self.reload
    # check if we need to deactivate the message for abuse
    if (user == self.conversation.owner) || DEV_TEAM.include?(user.login) || self.over_abuse_reports_limit?
      self.update_attributes(:abuse_report => abuse_report)
    end
  end

  #----------------------------------------------------------------------------
  def after_create 
    unless subscription = Subscription.find_by_user_id_and_conversation_id(user.id, conversation.id)
      subscription = user.subscriptions.create(:conversation => conversation)
    end
    subscription.mark_read!
    conversation.touch(:posted_at) #have to do it to make it update updated_at
  end
  
  #----------------------------------------------------------------------------
  def send_to_msg_broker_later
    if USE_WORKLING
      EchowavesWorker.asynch_send_to_msg_broker(:message_id => id)
    else
      self.send_to_msg_broker
    end
  end
  
  #----------------------------------------------------------------------------
  def send_to_msg_broker
    msg = self.custom_json
    channel = "CONVERSATION_CHANNEL_" + (self.conversation.private? ? self.conversation.uuid : self.conversation.id.to_s)
    s = Stomp::Client.open('localhost',61613)
    s.send channel, msg
    s.close
    # EM.run do
    #   EM.connect 'localhost', 61613, StompClient do |c|
    #     c.connect
    #     c.send channel, msg
    #   end
    # end
  rescue SystemCallError
    logger.error "IO failed: " + $!
  end
  
  #----------------------------------------------------------------------------
  def date
    self.created_at.strftime '%Y/%m/%d'
  end
  
  #----------------------------------------------------------------------------
  def date_pretty_long
    self.created_at.strftime '%b %d, %Y %I:%M%p'
  end

  #----------------------------------------------------------------------------
  def time_pretty
    self.created_at.strftime '%I:%M%p'
  end
  
  # custom JSON for javascript templates
  # TODO: use localization placeholders
  #----------------------------------------------------------------------------
  def data_for_templates
    {
      :meta => {
        :has_attachment => self.has_attachment?,
        :has_image => self.has_image?,
        :has_file => self.has_file?
      },
      :message => {
        :id => self.id,
        :body => self.message_html,
        :unfiltered_body => self.message,
        :date => self.date_pretty_long,
        :time => self.time_pretty
      },
      :attachment => {
        :image_url => self.has_image? ? self.attachment.url(:big) : nil,
        :url => self.has_attachment? ? self.attachment.url : nil,
        :height => self.has_image? ? self.attachment_height : nil,
        :width => self.has_image? ? self.attachment_width : nil,
        :type => self.has_attachment? ? self.attachment_type : "none"
      },
      :convo => {
        :id => self.conversation_id,
        :name => "#{self.conversation.name.parameterize}"
      },
      :user => {
        :id => self.user.id,
        :login => self.user.login.parameterize.to_s,
        :gravatar_url => self.user.gravatar_url,
        :since => self.user.date,
        :convos_started => user.conversations.size,
        :messages_posted => user.messages.size,
        :following => user.following.size,
        :followers => user.followers.size
      }
    }
  end
  
  def custom_json
    data_for_templates.to_json
  end
  
  # XML
  #----------------------------------------------------------------------------
  alias_method :unsafe_to_xml, :to_xml
  
  def to_xml(options = {})
    excluded_by_default = [:abuse_report_id, :delta, :message, :something, :updated_at,
                           :attachment_file_size, :attachment_file_name, :attachment_height, 
                           :attachment_width, :attachment_updated_at ]
    options[:except] = (options[:except] ? options[:except] + excluded_by_default : excluded_by_default)   
    unsafe_to_xml(options)
  end
  
  # IMPORTANT: update the markup in /public/templates/message.ejs if you change
  # the markup below
  #----------------------------------------------------------------------------
  def attachment_markup
    if self.has_image?
      %Q( <div class="img_attachment"><a href="#{self.attachment.url}" style="display:block;height:#{self.attachment_height+40}px;width:#{self.attachment_width+40}px;"><img src="#{self.attachment.url(:big)}" alt="#{self.message}" height="#{self.attachment_height}" width="#{self.attachment_width}" /></a></div> )
    elsif self.has_file?
      %Q( <div class="file_attachment"><a href="#{self.attachment.url}" style="display:block;height:100px;"><img src="/images/icons/#{self.attachment_type}_large.jpg" alt="#{self.attachment_type}" height="100" /></a></div> )
    end
  end
  
end
