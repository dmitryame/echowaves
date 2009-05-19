# == Schema Info
# Schema version: 20090514235226
#
# Table name: users
#
#  id                          :integer(4)      not null, primary key
#  personal_conversation_id    :integer(4)
#  conversations_count         :integer(4)      default(0)
#  crypted_password            :string(128)     not null, default("")
#  email                       :string(100)
#  login                       :string(40)
#  messages_count              :integer(4)      default(0)
#  name                        :string(100)     default("")
#  perishable_token            :string(40)
#  persistence_token           :string(255)
#  receive_email_notifications :boolean(1)      default(TRUE)
#  remember_token              :string(40)
#  salt                        :string(128)     not null, default("")
#  single_access_token         :string(255)     not null
#  something                   :string(255)     default("")
#  subscriptions_count         :integer(4)      default(0)
#  time_zone                   :string(255)     default("UTC")
#  activated_at                :datetime
#  created_at                  :datetime
#  remember_token_expires_at   :datetime
#  updated_at                  :datetime

Factory.sequence :name do |n|
  "testname#{n}" 
end

Factory.sequence :email do |n|
  "person#{n}@example.com" 
end

Factory.sequence :password do |n|
  "Sup3r#{n}" 
end

Factory.define :user do |u|
  u.login { Factory.next :name }
  u.name { Factory.next :name }
  u.email { Factory.next :email }
  u.email_confirmation {|u| u.email }
  u.password { Factory.next :email }
  u.password_confirmation {|p| p.password }
  u.created_at Time.now
end


Factory.define :conversation do |conversation|
  conversation.name { Factory.next :name }
  conversation.description "this is a test conversation that serves no other purpose but test"
  conversation.association :user
end

Factory.define :message do |message|
  message.message { Factory.next :name }
  message.association :user
  message.association :conversation
end


Factory.define :subscription do |subscription|
  subscription.association :user
  subscription.association :conversation
end

Factory.define :conversation_visit do |conversation_visit|
  conversation_visit.association :user
  conversation_visit.association :conversation
end

Factory.define :abuse_report do |abuse_report|
  abuse_report.association :user
  abuse_report.association :message
end

Factory.define :invite do |invite|
  invite.association :user
  invite.association :conversation
end
