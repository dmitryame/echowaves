require 'paperclip'

class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  
  has_many :abuse_reports

  belongs_to :abuse_report
  
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
  
  named_scope :published,
              :conditions => { :abuse_report_id => nil }
  
  
  validates_attachment_size :attachment, :less_than => 5.megabytes
  validates_attachment_content_type :attachment, :content_type => [ 'application/pdf', 'application/x-pdf', 'application/x-download', 'application/rtf', 'image/gif', 'image/jpeg', 'image/png', 'image/tiff', 'image/rgb' ]
  
  validates_presence_of     :message

  validates_presence_of :user_id, :conversation_id

  #expected to return a new spawned conversation
  def spawn_new_conversation(user)
    @conversation = Conversation.new
    @conversation.created_by = user
    @conversation.name = "spawned from: " + self.message
    @conversation.description = self.message
    @conversation.parent_message = self
    @conversation.save
    return @conversation #just trying to be explicit
  end

  def after_create 
    subscription = Subscription.find(:first, :conditions => ["user_id = ? and conversation_id = ?", user.id, conversation.id])     
    # # find_by_user_and_conversation(:user => user, :conversation => conversation)
    # 
    if subscription == nil
      subscription = Subscription.new
      subscription.user_id = user.id
      subscription.conversation_id = conversation.id
      subscription.save      
    end
    subscription.mark_read
    # puts "new subscription: user:" + user.id.to_s + " conversation:" + conversation.id.to_s
  end

  
end
