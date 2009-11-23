# == Schema Info
# Schema version: 20090906125449
#
# Table name: conversations
#
#  id                  :integer(4)      not null, primary key
#  parent_message_id   :integer(4)
#  user_id             :integer(4)
#  delta               :boolean(1)
#  messages_count      :integer(4)      default(0)
#  name                :string(255)
#  private             :boolean(1)
#  read_only           :boolean(1)
#  something           :string(255)     default("")
#  subscriptions_count :integer(4)      default(0)
#  uuid                :string(255)
#  created_at          :datetime
#  posted_at           :datetime
#  updated_at          :datetime

require File.expand_path(File.dirname(__FILE__) + "/../../lib/uuid")

class Conversation < ActiveRecord::Base
  
  before_validation_on_create :generate_uuid
  acts_as_taggable_on :tags, :bookmarks
  
  belongs_to :user, :counter_cache => true
  belongs_to :parent_message, # parent message it was spawned from, in case it was created by spawning
    :class_name => "Message",
    :foreign_key => "parent_message_id"

  has_many :messages # these are the conversations messages
  has_many :subscriptions
  has_many :users, :through => :subscriptions, :uniq => true,:order => "login ASC" # followers,  subscribers
  has_many :recent_followers, 
    :through => :subscriptions, 
    :source => :user, 
    :uniq => true, 
    :order => "subscriptions.created_at DESC",
    :limit => 10

  validates_presence_of     :name
#  validates_uniqueness_of   :name,      :unless => :spawned?
  validates_length_of       :name,      :within => 3..100
  validates_format_of       :something, :with => /^$/ # anti spam, honeypot field must be blank
  validates_presence_of     :uuid

  named_scope :non_private, :conditions => { :private => false }
  named_scope :no_owned_by, lambda { |user_id| { :conditions => ['conversations.user_id <> ?', user_id] }}

  # sphinx index
  define_index do
    indexes :name
    has created_at
    set_property :delta => :delayed
  end

  def self.most_popular
    #conversations = ConversationVisit.find(:all, :conditions => ["updated_at >= ?", Date.today - 30.days ], :group => :conversation_id, :order => "visits_count DESC", :limit => 10).map { |convo_visit| convo_visit.conversation }
    #conversations
    Conversation.find(:all, :order => "posted_at DESC", :limit => 5)
  end

  ##
  # instance methods
  #
  def total_visits
    ConversationVisit.find(:first, :group => :conversation_id, :conditions => ["conversation_id = ?", self.id]).visits_count
  end

  def owner
    self.user
  end

  def escaped_name
    escaped(self.name)
  end

  def followed_by?(user)
    self.subscriptions.find_by_user_id( user.id ).nil? ? false : true
  end

  def readable_by?(user)
    return false if user.blank?
    self.owner == user ||
    !self.private? ||
    self.followed_by?(user)
  end

  def writable_by?(user)
    self.owner == user || 
    ( !self.read_only && !self.private? ) ||
    ( self.private? && self.followed_by?(user) && !self.read_only )
  end

  def public?
    !self.private?
  end

  def spawned?
    !self.parent_message_id.nil?
  end

  def add_visit(user)
    if cv = ConversationVisit.find_by_user_id_and_conversation_id(user.id, self.id)
      cv.increment!( :visits_count ) 
    else
      user.conversation_visits.create( :conversation => self )
    end
  end

  def add_subscription(user)
    self.subscriptions.create( :user => user )
  end

  def remove_subscription(user)
    sub = self.subscriptions.find_all_by_user_id( user.id )
    sub.empty? ? true : sub.each { |s| s.destroy }
  end

  def messages_before(first_message_id)
    self.messages.published.find(:all, :include => [:user], :conditions => ["id < ?", first_message_id], :limit => Message::PER_PAGE, :order => 'id DESC')
  end

  def has_messages_before?(first_message)
    return false if(first_message == nil)
    messages = self.messages.published.find(:first, :conditions => ["id < ?", first_message.id], :order => 'id DESC') 
    messages ? true : false
  end

  def messages_after(last_message_id)
   self.messages.published.find(:all, :include => [:user], :conditions => ["id > ?", last_message_id], :limit => Message::PER_PAGE, :order => 'id ASC').reverse
  end

  def has_messages_after?(last_message)
    return false if(last_message == nil)
    messages = self.messages.published.find(:first, :conditions => ["id > ?", last_message.id], :order => 'id ASC')
    messages ? true : false
  end

  def after_create
    owner.follow(self)
    self.user.tag(self, :with => self.tag_list.to_s  + ", " + self.user.login, :on => :tags)
  end

  def date_time12
    self.created_at.strftime '%m/%d/%Y %I:%M%p'
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def reset_uuid!
    generate_uuid
    self.save
  end

  def generate_uuid
    self.uuid = UUID.create_v4.to_s
  end

end
