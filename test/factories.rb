Factory.sequence :name do |n|
  "testname#{n}" 
end

Factory.sequence :email do |n|
  "person#{n}@example.com" 
end

Factory.sequence :password do |n|
  "Sup3r#{n}" 
end

Factory.sequence :id do |n|
  n
end

Factory.define :user do |u|
  u.id { Factory.next :id }
  u.login { Factory.next :name }
  u.email { Factory.next :email }
  u.password { Factory.next :email }
  u.password_confirmation {|p| p.password }
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
