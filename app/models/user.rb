require 'digest/sha1'
require 'gravtastic'

class User < ActiveRecord::Base
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  acts_as_tagger
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  attr_accessor :email_confirmation
  validates_confirmation_of :email 
  

  # validates_presence_of     :personal_conversation_id #don't require it
  validates_uniqueness_of   :personal_conversation_id, :if => Proc.new { |u| !u.personal_conversation_id.blank? } 
  def validate
    self.errors.add(:something, "This field must be empty") unless self.something == ""
  end
  
  has_many :messages

  belongs_to :personal_conversation, #personal users conversation
    :class_name => "Conversation", 
    :foreign_key => "personal_conversation_id"


  has_many :subscriptions, :order => "activated_at DESC"
  has_many :subscribed_conversations, :through => :subscriptions, :uniq => true, :order => "name", :source => :conversation
  has_many :conversations

  has_many :conversation_visits
  has_many :recent_conversations, 
           :through => :conversation_visits, 
           :source => :conversation,
           :conditions => { :abuse_report_id => nil },
           :order => "conversation_visits.updated_at DESC",
           :limit => 10
  
  before_create :make_activation_code 

  named_scope :active, :conditions => "activated_at is not null"

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :email_confirmation, :name, :password, :password_confirmation, :time_zone, :something

  
  
  is_gravtastic :size => 40, :default => "identicon" # "monsterid" or "identicon", or "wavatar"
  
  #this returns friends convos
  def friends_convos
    self.subscribed_conversations.published.personal - [self.personal_conversation]
  end

  #this returns friends (users)
  def friends
    self.friends_convos.map {|convo| convo.user}
  end
    
  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    
    # create initial personal conversation
    conversation = Conversation.add_personal(self)
    self.personal_conversation_id = conversation.id

    self.save
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end
  
  # same as make_activation_code
  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end  

  #used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end
  
  def recently_reset_password?
    @reset_password
  end

  def mark_last_viewed_as_read
    self.subscriptions(:order => 'activated_at DESC').first.mark_read unless self.subscriptions.empty?
  end

  def update_last_viewed_subscription(conversation)
    if sub = self.subscriptions.find_by_conversation_id(conversation.id)
      sub.activate
    end
  end

  def conversation_visit_update(conversation)
    conversation.add_visit(self)
    self.mark_last_viewed_as_read
    self.update_last_viewed_subscription(conversation)
  end

  def follow(convo)
    subscription = convo.add_subscription(self)
    subscription.mark_read
  end
  
  def unfollow(convo)
    convo.remove_subscription(self)
  end
  
  def all_convos_tags
    tags = [] #have to initialize the array
    self.subscriptions.each do |subscription|
      subscription.conversation.taggings.each do |tagging|
        tags |= [tagging.tag]#removing duplicate tags
      end
    end
    tags
  end
  
  def all_convos_tag_counts
    tag_counts = [] #have to initialize the array
    puts "subscriptions count: " + self.subscriptions.size.to_s
    self.subscriptions.each do |subscription|      
      tag_counts |= subscription.conversation.tag_counts
    end
    tag_counts
  end
  
  def convos_by_tag(tag)
    convos = []
    self.subscriptions.each do |subscription|
      subscription.conversation.taggings.each do |tagging|
        convos |= [subscription.conversation] if(tagging.tag.to_s == tag)
      end
    end
    convos
  end

protected
    
  def make_activation_code
      self.activation_code = self.class.make_token
      logger.debug "Please activate your new account http://localhost:3000/activate/#{self.activation_code}"
  end
  
end
