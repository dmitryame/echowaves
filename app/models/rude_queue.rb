# == Schema Info
# Schema version: 20090906125449
#
# Table name: rude_queues
#
#  id         :integer(4)      not null, primary key
#  data       :text
#  processed  :boolean(1)      not null
#  queue_name :string(255)
#  created_at :datetime
#  updated_at :datetime

class RudeQueue < ActiveRecord::Base
  include RudeQ
end