# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def orbited_javascript
    [
    "<script src=\"http://#{ORBITED_HOST}:#{ORBITED_PORT}/static/Orbited.js\"></script>",
    '<script>',
    "  document.domain = '#{ORBITED_DOMAIN}';",
    "  Orbited.settings.port = #{ORBITED_PORT};",
    "  Orbited.settings.hostname = '#{ORBITED_HOST}';",
    '  TCPSocket = Orbited.TCPSocket;',
    '</script>',
    "<script src=\"http://#{ORBITED_HOST}:#{ORBITED_PORT}/static/protocols/stomp/stomp.js\"></script>"
    ].join("\n")
  end

  def flash_messages
    '<div id="flash_messages">' + (flash[:notice] ? "<div class=\"notice\">#{flash[:notice]}</div>": "") + (flash[:error] ? "<div class=\"error\">#{flash[:error]}</div>" : "") + '</div>'
  end

  # def format_date_for_message_meta(dt)
  #   daysold = (Time.now - dt) / 60 / 60 / 24
  #   case
  #   when daysold < 1
  #     "today" + dt.to_s(:recent)
  #   when daysold < 2
  #     "yesterday " + dt.to_s(:recent)
  #   else
  #     dt.to_s(:pretty_long)
  #   end
  # end
  
end
