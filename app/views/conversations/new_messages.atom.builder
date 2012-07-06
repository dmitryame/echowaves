atom_feed(:schema_date => "2008-04-22") do |feed|
  feed.title("New messages for #{@current_user.login}")

  for subscription in @news
  	messages_count = subscription.new_messages_count
  	feed.entry(subscription.conversation) do |entry|
  	  entry.title(subscription.conversation.name)
  	  entry.content(messages_count, :type => 'html')
  	end
  end
end