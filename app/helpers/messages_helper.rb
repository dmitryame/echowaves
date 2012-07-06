module MessagesHelper

  def mark_up(message)
    "#{message.attachment_markup} #{message.message_html}"
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
