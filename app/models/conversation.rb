class Conversation < ActiveRecord::Base
  
  validates_presence_of :name
  validates_presence_of :description

  # do not validate the uniquness of the personal conversations names, they will be guaranteed to be unique since the user names will be
  validates_uniqueness_of   :name,                       :unless => :personal? or :spawned?
  validates_length_of       :name,    :within => 3..100, :unless => :personal? 
  
  validates_length_of       :description, :maximum => 10000
  
  has_many :messages #these are the conversations messages
  belongs_to :parent_message, #parent message it was spawned from, in case it was created by spawning
  :class_name => "Message",
  :foreign_key => "parent_message_id"

  has_many :subscriptions
  has_many :users, :through => :subscriptions, :uniq => true,:order => "login ASC"
  has_many :recent_followers, 
  :through => :subscriptions, 
  :source => :user, 
  :uniq => true, 
  :order => "subscriptions.created_at DESC",
  :limit => 10

  has_many :abuse_reports #all the abuse report that were filed agains this convi
  belongs_to :abuse_report #the abuse report record that made this convo disabled

  belongs_to :user, :counter_cache => true

  named_scope :published, :conditions => { :abuse_report_id => nil }
  named_scope :not_personal, :conditions => { :personal_conversation => false }

  define_index do
    indexes :name
    indexes description
    has created_at
    set_property :delta => true
  end
  
  class << self
    def add_personal(user)
      name = user.name || user.login
      desc = "This is a personal conversation for #{name}. If you wish to collaborate with #{name}, do it here."
      convo = user.conversations.create(:name => user.login, :personal_conversation => true, :description => desc)

      convo
    end
  end

  
  def owner 
    self.user
  end
  
  def writable_by?(user)
    self.owner == user || !self.read_only
  end

  def personal?
    self.personal_conversation
  end
  
  def spawned?
    self.parent_message_id == nil
  end
  
  def followed?(user)    
    Subscription.find_by_conversation_id_and_user_id(self.id, user.id) ? true : false
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
    sub = self.subscriptions.find_by_user_id( user.id )
    sub.destroy if sub
  end

  def over_abuse_reports_limit?
    self.abuse_reports.size > CONVERSATION_ABUSE_THRESHOLD
  end

  def report_abuse(user)
    unless abuse_report = self.abuse_reports.find_by_user_id( user.id )
      abuse_report = self.abuse_reports.create( :user => user )
    end
    self.reload
    
    # check if we should deactivate the convo for abuse
    if (user == self.owner) or self.over_abuse_reports_limit?
      self.update_attributes( :abuse_report => abuse_report )
    end
  end

  def notify_of_new_spawn(user, spawn, message)
    msg = %Q(
      new convo: #{HOST}/conversations/#{spawn.id}/messages"
      spawned by: #{user.login}

      in response to: #{HOST}/conversations/#{self.id}/messages/#{message.id}
      #{message.message}
    )
    notification = user.messages.create( :conversation => self, :message => msg )
  end

  def escaped_name
    escaped(self.name)
  end

  def escaped_description
    escaped(self.description)
  end


  def get_messages_before(first_message_id)
    self.messages.published.find(:all, :include => [:user], :conditions => ["id < ?", first_message_id], :limit => 100, :order => 'id DESC')
  end
  def has_messages_before?(first_message)
    false if(first_message == nil)
    messages = self.messages.published.find(:first, :conditions => ["id < ?", first_message.id], :order => 'id DESC') 
    messages ? true : false
  end
  
  def get_messages_after(last_message_id)
   self.messages.published.find(:all, :include => [:user], :conditions => ["id > ?", last_message_id], :limit => 100, :order => 'id ASC').reverse
  end
  def has_messages_after?(last_message)
    false if(last_message == nil)
    messages = self.messages.published.find(:first, :conditions => ["id > ?", last_message.id], :order => 'id ASC') 
    messages ? true : false
  end


  def after_create 
    owner.follow(self)
  end



private
  def escaped(value)
    value.gsub(/"/, '&quot;').gsub(/'/, '.').gsub(/(\r\n|\n|\r)/,' <br />')
  end
end
