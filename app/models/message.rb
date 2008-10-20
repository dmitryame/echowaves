require 'paperclip'

class Message < ActiveRecord::Base
  acts_as_tree :order => "created_at DESC"
  belongs_to :conversation
  belongs_to :user
  
  has_attached_file :attachment

  validates_presence_of     :message
  
end
