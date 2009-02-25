require 'gravtastic'

class User < ActiveRecord::Base
  
  acts_as_authentic :transition_from_restful_authentication => true,
                    :perishable_token_field => 'activation_code'                    
  
  acts_as_tagger
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => LOGIN_REGEX, :message => "use only letters, numbers, and .-_@ please.".freeze

  validates_format_of       :name,     :with => NAME_REGEX,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => EMAIL_REGEX, :message => "should look like an email address.".freeze
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
  

  named_scope :active, :conditions => "activated_at is not null"

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :email_confirmation, :name, :password, :password_confirmation, :time_zone, :something

  is_gravtastic :size => 40, :default => "identicon" # "monsterid" or "identicon", or "wavatar"

  #this method returns a collection of all the convos with the new messages for the user.
  def news
    subscriptions = self.subscriptions.reject { |subscription| subscription.new_messages_count == 0 }
  end

  #this returns friends convos
  def friends_convos
    self.subscribed_conversations.published.personal - [self.personal_conversation]
  end

  #this returns friends (users)
  def friends
    self.friends_convos.map {|convo| convo.user}
  end
  
  def deliver_password_reset_instructions!
    reset_activation_code!
    UserMailer.deliver_password_reset_instructions(self)
  end
    
  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    # self.activation_code = nil
    
    # create initial personal conversation
    conversation = Conversation.add_personal(self)
    self.personal_conversation_id = conversation.id
  
    self.save
  end

  def active?
    self.activated_at != nil
  end
  
  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
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

  def follow(convo, token=nil)
    if !convo.private? || self == convo.owner
      subscription = convo.add_subscription(self)
      subscription.mark_read
      return true
    elsif convo.private? && ( token == self.activation_code )
      subscription = convo.add_subscription(self)
      subscription.mark_read
      self.reset_activation_code!
      return true
    else
      return false
    end
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
    # puts "subscriptions count: " + self.subscriptions.size.to_s
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

  alias_method :unsafe_to_xml, :to_xml
  
  def to_xml(options = {})
    excluded_by_default = [:crypted_password, :salt, :remember_token,
                          :remember_token_expires_at, :activated_at, :activation_code,
                          :email, :password_reset_code]
    options[:except] = (options[:except] ? options[:except] + excluded_by_default : excluded_by_default)   
    unsafe_to_xml(options)
  end
  
end
