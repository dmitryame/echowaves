class UserSession < Authlogic::Session::Base
  single_access_allowed_request_types ["text/html","application/atom+xml","application/xml","application/json"]
end