atom_feed(:schema_date => "2008-04-22") do |feed|
  feed.title("New users")
  feed.updated((@users.first.created_at))

  for user in @users
    feed.entry(user) do |entry|
      entry.title(user.name)
      entry.content(user.personal_conversation.escaped_description, :type => 'html')
    end
  end
end