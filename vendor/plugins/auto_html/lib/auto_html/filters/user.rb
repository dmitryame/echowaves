AutoHtml.add_filter(:user).with({}) do |text, options|
  text.gsub(/(^|\s|\.|\,)@(\w+)/) do
    username = $2
    " #{$1}<span class='twitter_like_username'>@</span><a href='/users/#{username}'>#{username}</a>"
  end
end
