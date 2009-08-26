# == Schema Info
# Schema version: 20090825132952
#
# Table name: users
#
#  id                          :integer(4)      not null, primary key
#  conversations_count         :integer(4)      default(0)
#  crypted_password            :string(128)     not null, default("")
#  delta                       :boolean(1)
#  email                       :string(100)
#  login                       :string(40)
#  messages_count              :integer(4)      default(0)
#  name                        :string(100)     default("")
#  perishable_token            :string(40)
#  persistence_token           :string(255)
#  receive_email_notifications :boolean(1)      default(TRUE)
#  remember_token              :string(40)
#  salt                        :string(128)     not null, default("")
#  single_access_token         :string(255)     not null
#  something                   :string(255)     default("")
#  subscriptions_count         :integer(4)      default(0)
#  time_zone                   :string(255)     default("UTC")
#  activated_at                :datetime
#  created_at                  :datetime
#  remember_token_expires_at   :datetime
#  updated_at                  :datetime

class User < ActiveRecord::Base
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :name, :password, :password_confirmation, :time_zone, :something, :receive_email_notifications
  attr_accessor :email_confirmation
    
  is_gravtastic :size => 60, :rating => 'G', :default => "identicon" # "monsterid" or "identicon", or "wavatar"

  acts_as_tagger
  acts_as_authentic do |c|
    c.transition_from_restful_authentication = true
  end
    
  has_many :messages
  has_many :client_applications
  has_many :tokens, :class_name => "OauthToken", :order => "authorized_at desc", :include => [:client_application]
  has_many :subscriptions, :order => "activated_at DESC"
  has_many :subscribed_conversations, :through => :subscriptions, :uniq => true, :order => "name", :source => :conversation  
  has_many :conversations
  has_many :conversation_visits
  has_many :recent_conversations, 
           :through => :conversation_visits, 
           :source => :conversation,
           :order => "conversation_visits.updated_at DESC",
           :limit => 10
  
  has_many :friendships
  has_many :friend_requests_by_me,  :foreign_key => :user_id,   :class_name => "Friendship"
  has_many :friend_requests_for_me, :foreign_key => :friend_id, :class_name => "Friendship"
  has_many :following,
           :through => :friend_requests_by_me,
           :source => :requested_for_me
  has_many :followers,
           :through => :friend_requests_for_me,
           :source => :requested_by_me
  
  # sphinx index
  define_index do
    indexes :login
    indexes :name
    has created_at
    where "activated_at != '@nil@'"
    set_property :delta => :delayed
  end
           
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => LOGIN_REGEX, :message => "use only letters, numbers, and .-_@ please.".freeze
  validates_format_of       :name,     :with => NAME_REGEX,  :message => "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze, :allow_nil => true
  validates_length_of       :name,     :maximum => 100
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 # r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => EMAIL_REGEX, :message => "should look like an email address.".freeze
  validates_confirmation_of :email 
  validates_format_of       :something, :with => /^$/ # anti spam, honeypot field must be blank
  
  named_scope :active, :conditions => "activated_at is not null"
  
  # this method returns a collection of all the convos with the new messages for the user.
  def news
    # the old way
    # subscriptions = self.subscriptions.reject { |subscription| subscription.new_messages_count == 0 }
    # the new way, slightly more efficient
    subscriptions = Subscription.find(:all, 
    :joins => "JOIN conversations ON subscriptions.conversation_id=conversations.id JOIN messages ON conversations.id = messages.conversation_id and messages.id > subscriptions.last_message_id",
    :conditions => ["subscriptions.user_id = ? and messages.system_message = 0 ", self.id ], 
    :group => "conversations.id",
    :order => "messages.id ASC",
    :limit => 12)
  end
  
  # friends system
  # you can follow or be followed by other users
  # if two users are mutually following each other, the two users become friends
  def follow_user(user)
    Friendship.create!(:user_id => self.id, :friend_id => user.id) unless user.id == self.id
  end
    
  def friends
    (self.following & self.followers).uniq  
  end
  
  def unfollow_user(user)
    Friendship.find(:first, :conditions => ['user_id = ? AND friend_id = ?', self.id, user.id] ).destroy
  end

  def following?(friend)
    self.following.include?(friend)
  end
  
  def friend_of?(friend)
    self.following?(friend) and friend.following?(self)
  end
      
  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.deliver_password_reset_instructions(self)
  end
  
  def deliver_private_invite_instructions!(invite)
    reset_perishable_token!
    if USE_WORKLING
      EchowavesWorker.asynch_deliver_private_invite_instructions(:user_id => id, :invite_id => invite.id)
    else
      UserMailer.deliver_private_invite_instructions(self, invite.conversation_id, invite.conversation.name, invite.requestor, invite.token)
    end
  end
  
  def deliver_public_invite_instructions!(invite)
    return unless self.receive_email_notifications
    if USE_WORKLING
      EchowavesWorker.asynch_deliver_public_invite_instructions(:user_id => id, :invite_id => invite.id)
    else
      UserMailer.deliver_public_invite_instructions(self, invite.conversation_id, invite.conversation.name, invite.requestor)
    end    
  end
  
  def activate!
    self.activated_at = Time.now.utc
    # create initial personal conversation
    # conversation = Conversation.add_personal(self)
    # self.personal_conversation_id = conversation.id
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
    self.subscriptions(:order => 'activated_at DESC').first.mark_read! unless self.subscriptions.empty?
  end

  def update_last_viewed_subscription(conversation)
    if sub = self.subscriptions.find_by_conversation_id(conversation.id)
      sub.activate!
    end
  end

  def conversation_visit_update(conversation)
    conversation.add_visit(self)
    self.mark_last_viewed_as_read
    self.update_last_viewed_subscription(conversation)
  end

  def follow(convo, token=nil)
    invite = Invite.find(:first, :conditions => ["user_id = ? and conversation_id = ?", self, convo.id ])
    if !convo.private? || self == convo.owner      
      #create a subscription if not created yet
      if (!Subscription.find_by_conversation_id_and_user_id(convo, self))
        subscription = convo.add_subscription(self) 
        subscription.mark_read!
      end
    elsif convo.private? && !invite.blank? && ( token == invite.token )
      #create a subscription if not created yet
      if (!Subscription.find_by_conversation_id_and_user_id(convo, self))
        subscription = convo.add_subscription(self) 
        subscription.mark_read!
      end
      invite.reset_token!
    else
      return false
    end
    return true
  end
  
  def unfollow(convo)
    convo.remove_subscription(self)
    # remove invitation if exists so the user can be invited again
    invite = Invite.find(:first, :conditions => ["user_id = ? and conversation_id = ?", self, convo.id ])
    invite.destroy unless invite.blank?
  end
  
  def all_convos_tags
    tags = [] # have to initialize the array
    self.subscriptions.each do |subscription|
      subscription.conversation.taggings.each do |tagging|
        tags |= [tagging.tag] # removing duplicate tags
      end
    end
    tags
  end

  # check if user can be invited to conversation by invitee
  def can_be_invited_to?(conversation, invitee)
    return false if conversation.users.include? self
    existing_invite = Invite.find( :first, :conditions => [ "user_id = ? and requestor_id = ? and conversation_id = ?", self.id, invitee.id, conversation.id ] )
    afirmative_condition_1 = existing_invite.blank?
    afirmative_condition_2 = existing_invite.present? && existing_invite.private? && conversation.public?
    afirmative_condition_3 = existing_invite.present? && existing_invite.public? && conversation.private?
    (afirmative_condition_1 || afirmative_condition_2 || afirmative_condition_3) ? true : false
  end
  
  #----------------------------------------------------------------------------
  def invite(conversation, invitee) 
    return unless self.can_be_invited_to?(conversation, invitee)
    existing_invite = Invite.find( :first, :conditions => [ "user_id = ? and requestor_id = ? and conversation_id = ?", self.id, invitee.id, conversation.id ] )
    # destroy the old invite if present
    existing_invite.destroy if( existing_invite.present? )
    invite = Invite.new
    invite.user_id = self.id
    invite.requestor = invitee
    invite.conversation_id = conversation.id
    invite.token = self.perishable_token if conversation.private?
    invite.save
 
    if conversation.private?
      # private convo only sends invite via email
      self.deliver_private_invite_instructions!(invite)      
    else
      self.deliver_public_invite_instructions!(invite)
    end
  end
  
  #----------------------------------------------------------------------------
  def all_convos_tag_counts
    tag_counts = [] # have to initialize the array
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

  def date
    self.created_at.strftime '%b %d, %Y'
  end
  
  def name_and_nick
    (self.name.blank? or self.name == self.login) ? self.login : "#{self.name} (#{self.login})"
  end
  
  def bookmark_tag
    "star_#{self.id}"
  end
  
  alias_method :unsafe_to_xml, :to_xml
  
  def to_xml(options = {})
    excluded_by_default = [:crypted_password, :salt, :remember_token, :something,
                          :remember_token_expires_at, :activated_at, :perishable_token, :persistence_token,
                          :single_access_token, :email, :receive_email_notifications]
    options[:except] = (options[:except] ? options[:except] + excluded_by_default : excluded_by_default)   
    unsafe_to_xml(options)
  end
  
  def to_param
    "#{id}-#{login.parameterize}"
  end
  
end
