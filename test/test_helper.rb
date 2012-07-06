ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
%w(test_help factory_girl).each { |lib| require lib }
require File.expand_path(File.dirname(__FILE__) + "/factories")
require 'authlogic/testing/test_unit_helpers'

require "webrat"
Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all

  #this method creates a admin/admin account, sets all the models with the relationships to give full authorization to the whole site, and authenticates
  def create_user_and_authenticate
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @user = Factory(:user, :login => "admin", :name => "Dmitry Amelchenko", :email => "qwe@mail.com", :password => "password", :password_confirmation => "password")

    #activate the user so it can be logged in to
    @user.activate!

    @request.env['HTTP_AUTHORIZATION'] =
    ActionController::HttpAuthentication::Basic.encode_credentials(
    "admin",
    "password"
    )
    @user
  end

  def assert_flash( _key, _content )
    assert flash.include?( _key ), "#{_key.inspect} missing from flash, has #{flash.keys.inspect}"

    case _content
    when Regexp then
      assert_match _content, flash[_key], "Content of flash[#{_key.inspect}] did not match"
    else
      assert_equal _conent, flash[_key], "Incorrect content in flash[#{_key.inspect}]"
    end
  end

  def self.should_have_attached_file(attachment)
    klass = self.name.gsub(/Test$/, '').constantize

    context "To support a paperclip attachment named #{attachment}, #{klass}" do
      should_have_db_column("#{attachment}_file_name",    :type => :string)
      should_have_db_column("#{attachment}_content_type", :type => :string)
      should_have_db_column("#{attachment}_file_size",    :type => :integer)
    end

    should "have a paperclip attachment named ##{attachment}" do
      assert klass.new.respond_to?(attachment.to_sym),
             "@#{klass.name.underscore} doesn't have a paperclip field named #{attachment}"
      assert_equal Paperclip::Attachment, klass.new.send(attachment.to_sym).class
    end
  end

  #----------------------------------------------------------------------------
  def login_as(login)
    post_via_redirect "/user_session", :user_session => { :login => login, :password => "secret" }
  end

  def goto_convo(convo)
    get "/conversations/#{conversations(convo).id}/messages.json"
    get "/conversations/#{conversations(convo).id}"
  end

  def goto_convo_api(convo, format)
    get "/conversations/#{conversations(convo).id}/messages.#{format}"
  end
end

class Module
   def redefine_const(name, value)
     __send__(:remove_const, name) if const_defined?(name)
     const_set(name, value)
   end
end