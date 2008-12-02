module MessagesHelper

  def mark_up(message)
    parts = message.split "\n"
    parts.map {|s| h(s)}.join(" <br/>").gsub(/(http|https|ftp)([^ ]+)/i) {|s|  "<a href='#{s}' target='_blank'>#{s}</a>"}        
  end

  def xx_mark_up(message)
    require 'bluecloth'
    BlueCloth::new( message ).to_html
  end

  def display_attachment(message)
    if message.has_image?
      link_to( image_tag( message.attachment.url(:big) ), message.attachment.url, :target => '_blank' )
    elsif message.has_pdf?
      %Q(
        #{link_to( image_tag( 'icons/pdf_large.jpg', :alt => 'PDF Document' ), message.attachment.url, :target => '_blank' )}
        <br />
        #{link_to( message.attachment_file_name, message.attachment.url, :target => '_blank' )}
      )
    end
  end

end
