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

  belongs_to :user

  named_scope :published,
              :conditions => { :abuse_report_id => nil }

  named_scope :not_personal, :conditions => { :personal_conversation => false }

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
    (!user.subscriptions.empty? && user.subscriptions.find_by_conversation_id(self.id)) ? true : false
  end

  def add_visit(user)
    if cv = ConversationVisit.find_by_user_id_and_conversation_id(user.id, self.id)
      cv.increment!( :visits_count ) 
    else
      user.conversation_visits.create( :conversation => self )
    end
  end

  def self.add_personal(user)
    name = user.name || user.login
    desc = "This is a personal conversation for #{name}. If you wish to collaborate with #{name}, do it here."
    convo = user.conversations.create(:name => user.login, :personal_conversation => true, :description => desc)

    # create subscription to your own personal message automatically
    subscription = user.subscriptions.create(:conversation => convo) 
    convo
  end

  def escaped_name
    escaped(self.name)
  end

  def escaped_description
    escaped(self.description)
  end

private
  def escaped(value)
    value.gsub(/"/, '&quot;').gsub(/'/, '.').gsub(/(\r\n|\n|\r)/,' </br>')
  end
end
