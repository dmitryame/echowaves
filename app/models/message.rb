require 'paperclip'

class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  
  has_attached_file :attachment,
  :styles => {
    :thumb => "64x64>",
    :small => "150x150>",
    :big   => "400x400>" 
  },
  :path => PAPERCLIP_PATH,
  :url  => PAPERCLIP_URL

  validates_attachment_size :attachment, :less_than => 5.megabytes

  validates_presence_of     :message
  
end
