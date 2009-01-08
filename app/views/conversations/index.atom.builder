atom_feed(:schema_date => "2008-04-22") do |feed|
  feed.title("Recently started convos")
  feed.updated((@conversations.first.created_at))

  for convo in @conversations
    feed.entry(convo) do |entry|
      entry.title(convo.name)
      entry.content(convo.escaped_description, :type => 'html')

      entry.author do |author|
        author.name(convo.user.name)
      end
    end
  end
end