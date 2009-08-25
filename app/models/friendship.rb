class Friendship < ActiveRecord::Base
  belongs_to :requested_by_me,   :foreign_key => :user_id,   :class_name => "User"
  belongs_to :requested_for_me,  :foreign_key => :friend_id, :class_name => "User"
end