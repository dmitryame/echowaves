module MessagesHelper

  def mark_up(message)
    parts = message.split "\n"
    parts.map {|s| h(s)}.join(" <br/>").gsub(/(http|https|ftp)([^ ]+)/i) {|s|  "<a href='#{s}'>#{s}</a>"}        
  end

end
