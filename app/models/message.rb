class Message < ActiveRecord::Base
  
  attr_protected :system_message #add more attributes as needed to protect from mass assignment
  
  auto_html_for(:message) do
    html_escape
    gist
    youtube(:width => 400, :height => 250)
    vimeo
    image
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
    :url  => PAPERCLIP_URL
  
  named_scope :published, :conditions => { :abuse_report_id => nil }
  named_scope :with_file, :conditions => ["attachment_content_type like ?","application%"]
  named_scope :with_image, :conditions => ["attachment_content_type like ?",'image%']
  
  ##
  # sphinx index
  #
  define_index do
    indexes message
    has created_at
    has abuse_report_id
    has system_message
    set_property :delta => true
  end
          
  validates_attachment_size :attachment, :less_than => 5.megabytes
  validates_attachment_content_type :attachment, :content_type => [ 'application/msword', 'application/pdf', 'application/x-pdf', 'application/x-download', 'application/rtf', 'image/gif', 'image/jpeg', 'image/png', 'image/tiff', 'image/rgb', 'application/zip', 'application/x-gzip' ]
  validates_presence_of :user_id, :conversation_id, :message
  validates_format_of :something, :with => /^$/ # anti spam, honeypot field must be blank
    
  def published?
    self.abuse_report.nil?
  end

  def has_attachment?
    self.attachment.exists?
  end

  def has_pdf?
    has_attachment? and self.attachment_content_type.include?("pdf")
  end

  def has_image?
    has_attachment? and self.attachment_content_type.include?("image")
  end

  def has_zip?
    has_attachment? and self.attachment_content_type.include?("zip")
  end
  
  def over_abuse_reports_limit?
    self.abuse_reports.size > MESSAGE_ABUSE_THRESHOLD
  end

  # add an abuse report per user
  def report_abuse(user)
    unless abuse_report = self.abuse_reports.find_by_user_id(user.id)
      abuse_report = self.abuse_reports.create(:user => user)
    end
    self.reload
    # check if we need to deactivate the message for abuse
    if (user == self.conversation.owner) or self.over_abuse_reports_limit?
      self.update_attributes(:abuse_report => abuse_report)
      #
      # FIXME: why is this next line happening?  There has to be a better way to accomplish whatever is trying to be accomplished then issuing a system call!
      #        we need to take all OS setups into account, not just unix
      # perhaps this line is really important in publicly installed site like http://echowaves.com. could be parameterized for local installs
      #
      system "chmod -R 000 ./public/attachments/#{self.id}"
    end
  end

  def after_create 
    unless subscription = Subscription.find_by_user_id_and_conversation_id(user.id, conversation.id)
      subscription = user.subscriptions.create(:conversation => conversation)
    end
    subscription.mark_read
  end

  def send_stomp_message(context)
    newmessagescript = context.render_to_string(:partial => 'messages/message.html', :object => self)
    s = Stomp::Client.new
    s.send("CONVERSATION_CHANNEL_" + self.conversation.id.to_s, newmessagescript)
    s.close
  rescue SystemCallError
    logger.error "IO failed: " + $!
    # raise
  end
  
  def date
    self.created_at.strftime '%Y/%m/%d'
  end
  
  def date_pretty_long
    self.created_at.strftime '%b %d, %Y %I:%M%p'
  end

  def time_pretty
    self.created_at.strftime '%I:%M%p'
  end
  
end
