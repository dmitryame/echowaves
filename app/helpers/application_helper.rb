# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  def orbited_javascript
    [
    "<script src=\"http://#{ORBITED_HOST}:#{ORBITED_PORT}/static/Orbited.js\"></script>",
    '<script>',
    "  document.domain = '#{ORBITED_HOST}';",
    "  Orbited.settings.port = #{ORBITED_PORT};",
    "  Orbited.settings.hostname = '#{ORBITED_HOST}';",
    '  TCPSocket = Orbited.TCPSocket;',
    '</script>',
    "<script src=\"http://#{ORBITED_HOST}:#{ORBITED_PORT}/static/protocols/stomp/stomp.js\"></script>"
    ].join("\n")
  end
end