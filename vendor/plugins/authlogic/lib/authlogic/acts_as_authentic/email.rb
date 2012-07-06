module Authlogic
  module ActsAsAuthentic
    # Sometimes models won't have an explicit "login" or "username" field. Instead they want to use the email field.
    # In this case, authlogic provides validations to make sure the email submited is actually a valid email. Don't worry,
    # if you do have a login or username field, Authlogic will still validate your email field. One less thing you have to
    # worry about.
    module Email
      def self.included(klass)
        klass.class_eval do
          extend Config
          add_acts_as_authentic_module(Methods)
        end
      end

      # Configuration to modify how Authlogic handles the email field.
      module Config
        # The name of the field that stores email addresses.
        #
        # * <tt>Default:</tt> :email, if it exists
        # * <tt>Accepts:</tt> Symbol
        def email_field(value = nil)
          config(:email_field, value, first_column_to_exist(nil, :email))
        end
        alias_method :email_field=, :email_field

        # Toggles validating the email field or not.
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def validate_email_field(value = nil)
          config(:validate_email_field, value, true)
        end
        alias_method :validate_email_field=, :validate_email_field

        # A hash of options for the validates_length_of call for the email field. Allows you to change this however you want.
        #
        # * <tt>Default:</tt> {:within => 6..100}
        # * <tt>Accepts:</tt> Hash of options accepted by validates_length_of
        def validates_length_of_email_field_options(value = nil)
          config(:validates_length_of_email_field_options, value, {:within => 6..100})
        end
        alias_method :validates_length_of_email_field_options=, :validates_length_of_email_field_options

        # A hash of options for the validates_format_of call for the email field. Allows you to change this however you want.
        #
        # * <tt>Default:</tt> {:with => email_regex, :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address.")}
        # * <tt>Accepts:</tt> Hash of options accepted by validates_format_of
        def validates_format_of_email_field_options(value = nil)
          config(:validates_format_of_email_field_options, value, {:with => email_regex, :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address.")})
        end
        alias_method :validates_format_of_email_field_options=, :validates_format_of_email_field_options

        private
          def email_regex
            return @email_regex if @email_regex
            email_name_regex  = '[\w\.%\+\-]+'
            domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
            domain_tld_regex  = '(?:[A-Z]{2}|aero|ag|asia|at|be|biz|ca|cc|cn|com|de|edu|eu|fm|gov|gs|jobs|jp|in|info|me|mil|mobi|museum|ms|name|net|nu|nz|org|tc|tw|tv|uk|us|vg|ws)'
            @email_regex = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
          end
      end

      # All methods relating to the email field
      module Methods
        def self.included(klass)
          klass.class_eval do
            if validate_email_field && email_field
              validates_length_of email_field, validates_length_of_email_field_options
              validates_format_of email_field, validates_format_of_email_field_options
              validates_uniqueness_of email_field, :scope => validations_scope, :if => "#{email_field}_changed?".to_sym
            end
          end
        end
      end
    end
  end
end