class Conversation < ActiveRecord::Base
  
  validates_presence_of :name
  validates_presence_of :description

  # do not validate the uniquness of the personal conversations names, they will be guaranteed to be unique since the user names will be
  validates_uniqueness_of   :name,                       :unless => :personal?
  validates_length_of       :name,    :within => 8..100, :unless => :personal?
  
  validates_length_of       :description, :within => 0..10000
  
  has_many :messages

  has_many :subscriptions
  has_many :users, :through => :subscriptions, :uniq => true,:order => "login ASC"
  has_many :recent_followers, 
  :through => :subscriptions, 
  :source => :user, 
  :uniq => true, 
  :order => "subscriptions.created_at DESC",
  :limit => 10

  has_many :abuse_reports

  belongs_to :abuse_report

  named_scope :published,
              :conditions => { :abuse_report_id => nil }

  named_scope :not_personal, :conditions => { :personal_conversation => false }

  def owner 
    Message.find_by_conversation_id(self.id, :order => "id ASC").user
  end
  
  def writable_by?(user)
    self.owner == user || !self.read_only
  end

  def personal?
    self.personal_conversation
  end
  
  #virtual attribute requires only to make it possible to pass the user (current_user) who creted the conversation to after_create from controller
  attr_accessor :created_by

  def followed?(user)    
    if user.subscriptions.size > 0 && user.conversations.find(:all, :conditions => ["conversation_id = ?",self.id]).size > 0
      true
    else
      false
    end
  end


  def after_create 
    @message = Message.new
    @message.user = self.created_by
    @message.conversation = self
    @message.message = self.description
    @message.save
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