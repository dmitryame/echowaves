require 'rbconfig'

class JavascriptI18nGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "public/javascripts"
      m.directory "public/javascripts/i18n"
      m.file      "javascripts/base.js", "public/javascripts/i18n/base.js"

      m.directory "lib/tasks"
      m.file      "tasks/javascript_i18n.rake", "lib/tasks/javascript_i18n.rake"
    end
  end

  protected

  def banner
    "Usage: #{$0} javascript_i18n"
  end
end
