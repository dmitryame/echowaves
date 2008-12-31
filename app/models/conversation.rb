class Conversation < ActiveRecord::Base
  acts_as_taggable_on :tags
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
  has_many :users, :through => :subscriptions, :uniq => true,:order => "login ASC" #followers,  subscribers
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
  named_scope :personal, :conditions => { :personal_conversation => true }

  def validate
    self.errors.add(:something, "This field must be empty") unless self.something == ""
  end
  
  define_index do
    indexes :name
    indexes description
    has created_at
    has abuse_report_id
    set_property :delta => true
  end
  
  class << self
    def add_personal(user)
      name = user.name || user.login
      desc = "This is a personal conversation for #{name}. If you wish to collaborate with #{name}, do it here."
      convo = user.conversations.create(:name => user.login, :personal_conversation => true, :description => desc)
      convo.tag_list.add("personal_convo")
      convo.save

      convo
    end
  end # class << self

  def published?
    self.abuse_report.nil?
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
    !self.parent_message_id.nil?
  end
  
  def followed?(user)    
    self.subscriptions.find_by_user_id( user.id ).nil? ? false : true
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

  def over_abuse_reports_limit?
    self.abuse_reports.size > CONVERSATION_ABUSE_THRESHOLD
  end

  def report_abuse(user)
    unless abuse_report = self.abuse_reports.find_by_user_id( user.id )
      abuse_report = self.abuse_reports.create( :user => user )
    end
    self.reload
    
    # check if we should deactivate the convo for abuse
    if (user == self.owner and self != self.user.personal_conversation) or self.over_abuse_reports_limit?
      self.update_attributes( :abuse_report => abuse_report )
    end
  end

  def disabled_by_abuse_report?
    self.abuse_report_id == nil ? false : true
  end
  
  def notify_of_new_spawn(user)
    msg = %Q(
      new convo: <a href="#{HOST}/conversations/#{self.id}/messages">#{self.name}</a>
      spawned by: #{user.login}

      in response to: <a href="#{HOST}/conversations/#{self.parent_message.conversation_id}/messages/#{self.parent_message.id}">#{HOST}/conversations/#{self.parent_message.conversation_id}/messages/#{self.parent_message.id}</a>
    )
    notification = user.messages.create( :conversation => self.parent_message.conversation, :message => msg, :system_message => true)
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
  end



private
  def escaped(value)
    value.gsub(/"/, '&quot;').gsub(/'/, '.').gsub(/(\r\n|\n|\r)/,' <br />')
  end
end
