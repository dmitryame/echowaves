# == Schema Info
# Schema version: 20090514235226
#
# Table name: conversations
#
#  id                    :integer(4)      not null, primary key
#  parent_message_id     :integer(4)
#  user_id               :integer(4)
#  delta                 :boolean(1)
#  description           :text
#  messages_count        :integer(4)      default(0)
#  name                  :string(255)
#  personal_conversation :boolean(1)
#  private               :boolean(1)
#  read_only             :boolean(1)
#  something             :string(255)     default("")
#  subscriptions_count   :integer(4)      default(0)
#  created_at            :datetime
#  posted_at             :datetime
#  updated_at            :datetime
#----------------------------------------------------------------------------
class Conversation < ActiveRecord::Base
  
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

  # do not validate the uniquness of the personal conversations names, they will be guaranteed to be unique since the user names will be
  validates_presence_of     :name
  validates_uniqueness_of   :name,                       :unless => :personal? or :spawned?
  validates_length_of       :name,    :within => 3..100, :unless => :personal?
  validates_presence_of     :description
  validates_length_of       :description, :maximum => 10000
  validates_format_of       :something, :with => /^$/ # anti spam, honeypot field must be blank

  named_scope :non_private, :conditions => { :private => false }
  named_scope :not_personal, :conditions => { :personal_conversation => false }
  named_scope :personal, :conditions => { :personal_conversation => true }
  named_scope :no_owned_by, lambda { |user_id| { :conditions => ['conversations.user_id <> ?', user_id] }}
  
  # sphinx index
  define_index do
    indexes :name
    indexes description
    has created_at
    set_property :delta => true
  end
  
  ##
  # class methods
  #
  def self.add_personal(user)
    name = user.name || user.login
    desc = "This is a personal conversation for #{name}. If you wish to collaborate with #{name}, do it here."
    convo = user.conversations.create(:name => user.login, :personal_conversation => true, :description => desc)
    convo.tag_list.add("personal_convo")
    convo.save
    convo
  end

  def self.most_popular
    #conversations = ConversationVisit.find(:all, :conditions => ["updated_at >= ?", Date.today - 30.days ], :group => :conversation_id, :order => "visits_count DESC", :limit => 10).map { |convo_visit| convo_visit.conversation }          
    #conversations
    Conversation.find(:all, :order => "posted_at DESC", :limit => 10)
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

  def escaped_description
    escaped(self.description)
  end
  
  def followed_by?(user)
    self.subscriptions.find_by_user_id( user.id ).nil? ? false : true
  end
  
  def readable_by?(user)
    self.owner == user ||
    !self.private? ||
    self.followed_by?(user)
  end
  
  def writable_by?(user)
    self.owner == user || 
    ( !self.read_only && !self.private? ) ||
    ( self.private? && self.followed_by?(user) )
  end

  def personal?
    self.personal_conversation
  end
    
  def private?
    self.private
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

  def notify_of_new_spawn(user)
    msg = %Q(
      new convo: <a href="#{HOST}/conversations/#{self.id}">#{self.name}</a>
      spawned by: #{user.login}

      in response to: <a href="#{HOST}/conversations/#{self.parent_message.conversation_id}/messages/#{self.parent_message.id}">#{HOST}/conversations/#{self.parent_message.conversation_id}/messages/#{self.parent_message.id}</a>
    )
    notification = user.messages.create( :conversation => self.parent_message.conversation, :message => msg)
    notification.system_message = true
    notification.save
    return notification
  end

  def get_messages_before(first_message_id)
    self.messages.published.find(:all, :include => [:user], :conditions => ["id < ?", first_message_id], :limit => 100, :order => 'id DESC')
  end
  
  def has_messages_before?(first_message)
    return false if(first_message == nil)
    messages = self.messages.published.find(:first, :conditions => ["id < ?", first_message.id], :order => 'id DESC') 
    messages ? true : false
  end

  def get_messages_after(last_message_id)
   self.messages.published.find(:all, :include => [:user], :conditions => ["id > ?", last_message_id], :limit => 100, :order => 'id ASC').reverse
  end
  
  def has_messages_after?(last_message)
    return false if(last_message == nil)
    messages = self.messages.published.find(:first, :conditions => ["id > ?", last_message.id], :order => 'id ASC') 
    messages ? true : false
  end

  def after_create 
    owner.follow(self)
    self.user.tag(self, :with => self.tag_list.to_s  + ", " + self.user.login, :on => :tags)      
    #invite all my followers, if the convo is public
    unless(self.private?)
      self.user.followers.each do |u| 
        if(u.id != self.user.id) 
          u.invite self, self.user        
        end
      end
    end
    
  end
  
  def date_time12
    self.created_at.strftime '%m/%d/%Y %I:%M%p'
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
private

  def escaped(value)
    value.gsub(/"/, '&quot;').gsub(/'/, '.').gsub(/(\r\n|\n|\r)/,' <br />')
  end
  
end
