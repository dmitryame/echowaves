module MessagesHelper

  def xx_mark_up(message)
    parts = message.split "\n"
    parts.map {|s| h(s)}.join("<br/>")
  end

  def mark_up(message)
    require 'bluecloth'
    BlueCloth::new( message ).to_html
  end
end
