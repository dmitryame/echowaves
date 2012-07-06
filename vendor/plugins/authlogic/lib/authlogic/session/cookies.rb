module Authlogic
  module Session
    # Handles all authentication that deals with cookies, such as persisting a session and saving / destroying a session.
    module Cookies
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          persist :persist_by_cookie
          after_save :save_cookie
          after_destroy :destroy_cookie
        end
      end

      # Configuration for the cookie feature set.
      module Config
        # The name of the cookie or the key in the cookies hash. Be sure and use a unique name. If you have multiple sessions and they use the same cookie it will cause problems.
        # Also, if a id is set it will be inserted into the beginning of the string. Exmaple:
        #
        #   session = UserSession.new
        #   session.cookie_key => "user_credentials"
        #
        #   session = UserSession.new(:super_high_secret)
        #   session.cookie_key => "super_high_secret_user_credentials"
        #
        # * <tt>Default:</tt> "#{klass_name.underscore}_credentials"
        # * <tt>Accepts:</tt> String
        def cookie_key(value = nil)
          config(:cookie_key, value, "#{klass_name.underscore}_credentials")
        end
        alias_method :cookie_key=, :cookie_key

        # If sessions should be remembered by default or not.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def remember_me(value = nil)
          config(:remember_me, value, false)
        end
        alias_method :remember_me=, :remember_me

        # The length of time until the cookie expires.
        #
        # * <tt>Default:</tt> 3.months
        # * <tt>Accepts:</tt> Integer, length of time in seconds, such as 60 or 3.months
        def remember_me_for(value = :_read)
          config(:remember_me_for, value, 3.months, :_read)
        end
        alias_method :remember_me_for=, :remember_me_for
      end

      # The methods available for an Authlogic::Session::Base object that make up the cookie feature set.
      module InstanceMethods
        def credentials=(value)
          super
          values = value.is_a?(Array) ? value : [value]
          case values.first
          when Hash
            self.remember_me = values.first.with_indifferent_access[:remember_me]
          else
            r = values.find { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }
            self.remember_me = r if !r.nil?
          end
        end

        def remember_me # :nodoc:
          return @remember_me if defined?(@remember_me)
          @remember_me = self.class.remember_me
        end

        # Accepts a boolean as a flag to remember the session or not. Basically to expire the cookie at the end of the session or keep it for "remember_me_until".
        def remember_me=(value)
          @remember_me = value
        end

        # Allows users to be remembered via a cookie.
        def remember_me?
          remember_me == true || remember_me == "true" || remember_me == "1"
        end

        # How long to remember the user if remember_me is true. This is based on the class level configuration: remember_me_for
        def remember_me_for
          return unless remember_me?
          self.class.remember_me_for
        end

        # When to expire the cookie. See remember_me_for configuration option to change this.
        def remember_me_until
          return unless remember_me?
          remember_me_for.from_now
        end

        private
          def cookie_key
            build_key(self.class.cookie_key)
          end

          def cookie_credentials
            controller.cookies[cookie_key]
          end

          # Tries to validate the session from information in the cookie
          def persist_by_cookie
            if cookie_credentials
              self.unauthorized_record = search_for_record("find_by_persistence_token", cookie_credentials)
              valid?
            else
              false
            end
          end

          def save_cookie
            controller.cookies[cookie_key] = {
              :value => record.persistence_token,
              :expires => remember_me_until,
              :domain => controller.cookie_domain
            }
          end

          def destroy_cookie
            controller.cookies.delete cookie_key, :domain => controller.cookie_domain
          end
      end
    end
  end
end