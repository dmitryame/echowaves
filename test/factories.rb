Factory.sequence :name do |n|
  "name#{n}" 
end

Factory.sequence :email do |n|
  "person#{n}@example.com" 
end

Factory.sequence :password do |n|
  "Sup3r#{n}" 
end

Factory.define :conversation do |conversation|
  conversation.name {Factory.next :name }
end
