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
  u.login "JDough"
  u.email { Factory.next :email }
  u.password { Factory.next :email }
  u.password_confirmation {|p| p.password }
end


Factory.define :conversation do |conversation|
  conversation.name {Factory.next :name }
end
