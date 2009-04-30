# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.

  config.gem "gravtastic"
  config.gem "stomp"
  config.gem "oauth", :version => '0.3.2'
  
  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_echowaves_session',
    :secret      => '66ff24ef9207ebaa90231b6b28bfac105da30650f733823e77de8afffa0297d7933eff5d83fa941bb12fb7cd78a46cf3636d5f855b7a39c1c0033f6156290a27'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  # Second, add the :user_observer
  # Rails::Initializer.run do |config|
  # The user observer goes inside the Rails::Initializer block
  # !!!!!!!!!!!!!the following line must be uncommented in production for users to be able to register
  # config.active_record.observers = :user_observer
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
end

# active mailer configuration
# First, specify the Host that we will be using later for user_notifier.rb
HOST = 'http://localhost:3000'

ActionMailer::Base.delivery_method = :smtp
# Third, add your SMTP settings
ActionMailer::Base.smtp_settings = {
  :address => "mail.rmgapps.com",
  :port => 25,
  :domain => "rmg-ny.com"
}

# emails sent from echowaves will use these parameters
BCC         = "dmitry@rootlocusinc.com" # email monitoring log
FROM        = "support@echowaves.com"
SUBJECT     = "[echowaves.com] "

ORBITED_HOST = 'localhost'
ORBITED_PORT = '8500'
ORBITED_DOMAIN = 'localhost'
STOMP_HOST = 'localhost'
STOMP_PORT = '61613'

HOME_CONVERSATION = 1
TEST_CONVERSATION = 3

#override to false in production
SHOW_ACTIVATION_LINK=true