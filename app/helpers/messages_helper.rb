module MessagesHelper

  def mark_up(message)
    parts = message.split "\n"
    parts.map {|s| h(s)}.join("<br/>")
  end

end
