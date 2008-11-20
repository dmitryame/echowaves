require 'paperclip'

class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  
  has_many :abuse_reports
  
  has_attached_file :attachment,
  :styles => {
    :thumb => "64x64>",
    :small => "150x150>",
    :big   => "400x400>" 
  },
  :path => PAPERCLIP_PATH,
  :url  => PAPERCLIP_URL

  validates_attachment_size :attachment, :less_than => 5.megabytes
  validates_attachment_content_type :attachment, :content_type => [ 'application/pdf', 'application/x-pdf', 'application/x-download', 'application/rtf', 'image/gif', 'image/jpeg', 'image/png', 'image/tiff', 'image/rgb' ]
  
  validates_presence_of     :message

  validates_presence_of :user_id, :conversation_id


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
    # puts "new subscription: user:" + user.id.to_s + " conversation:" + conversation.id.to_s
  end

  
end
