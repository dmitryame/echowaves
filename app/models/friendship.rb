# == Schema Info
# Schema version: 20090906125449
#
# Table name: friendships
#
#  id         :integer(4)      not null, primary key
#  friend_id  :integer(4)      not null
#  user_id    :integer(4)      not null
#  created_at :datetime
#  updated_at :datetime

class Friendship < ActiveRecord::Base
  belongs_to :requested_by_me,   :foreign_key => :user_id,   :class_name => "User"
  belongs_to :requested_for_me,  :foreign_key => :friend_id, :class_name => "User"
end