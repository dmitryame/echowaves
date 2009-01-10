module HomeHelper
  
  def home_menu_item
    if !logged_in?
      link_to t('ui.home'), home_path
    else
      link_to t('ui.home'),
        conversation_messages_path(current_user.personal_conversation),
        :class => 'tip', 
	    	:title => "personal convo for " + current_user.login
    end
  end
  
end
