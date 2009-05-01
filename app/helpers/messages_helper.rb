module MessagesHelper

  def mark_up(message)
    return message.message if message.system_message == true # no markup for system_messages
    # parts = message.message.split "\n"
    # parts.map {|s| h(s)}.join(" <br/>").gsub(/(http|https|ftp)([^ ]+)/i) {|s|  "<a href='#{s}' rel='nofollow'>#{s}</a>"}        
    message.message_html
  end

  def xx_mark_up(message)
    require 'bluecloth'
    BlueCloth::new( message ).to_html
  end

  def display_attachment(message)
    if message.has_image?
      '<div class="img_attachment">' + link_to( image_tag( message.attachment.url(:big), :alt => message.message ), message.attachment.url, :target => '_blank') + "</div>"
    elsif message.has_pdf?
      %Q(
        <div class="file_attachment">
        #{link_to( image_tag( 'icons/pdf_large.jpg', :alt => 'PDF Document', :width => 100 ), message.attachment.url, :target => '_blank' )}
        </div>
      )
    elsif message.has_zip?
      %Q(
        <div class="file_attachment">
        #{link_to( image_tag( 'icons/zip_large.jpg', :alt => 'ZIP File', :width => 82 ), message.attachment.url, :target => '_blank' )}
        </div>
      )
    end
  end
  
  def user_popup(user)
    image_tag(user.gravatar_url, :border => 0, :width => 60, :height => 60, :style => 'float:left;margin-right:15px;margin-bottom:15px;') +
    t("users.since") + user.date  + 
		'<br/>' + user.conversations.size.to_s  + '&nbsp;' + t('ui.convos') +
		'<br/>' + user.messages.size.to_s       + '&nbsp;' + t('ui.messages') +
		'<br/>' + user.subscriptions.size.to_s  + '&nbsp;' + t("ui.following") +
		'<br/>' + user.followers.size.to_s      + '&nbsp;' + t("ui.followers")
  end

end
