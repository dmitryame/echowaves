module MessagesHelper

  def mark_up(message)
    parts = message.split "\n"
    parts.map {|s| h(s)}.join(" <br/>").gsub(/(http|https|ftp)([^ ]+)/i) {|s|  "<a href='#{s}' TARGET=_BLANK>#{s}</a>"}        
  end

  def xx_mark_up(message)
    require 'bluecloth'
    BlueCloth::new( message ).to_html
  end
end
