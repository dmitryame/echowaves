PAPERCLIP_URL  = "/attachments/:id/:style/:basename.:extension"
PAPERCLIP_PATH = ":rails_root/public/attachments/:id/:style/:basename.:extension"

MESSAGE_ABUSE_THRESHOLD = 2 # number of abuse_reports a message can receive before being deactivated


# From restful_authentication plugin
LOGIN_REGEX = /\A\w[\w\.\-_@]+\z/ # ASCII, strict
# LOGIN_REGEX = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/ # Unicode, strict
# LOGIN_REGEX = /\A[^[:cntrl:]\\<>\/&]*\z/ # Unicode, permissive
NAME_REGEX = /\A[^[:cntrl:]\\<>\/&]*\z/ # Unicode, permissive
EMAIL_NAME_REGEX = '[\w\.%\+\-]+'.freeze
DOMAIN_HEAD_REGEX = '(?:[A-Z0-9\-]+\.)+'.freeze
DOMAIN_TLD_REGEX = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
EMAIL_REGEX = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i