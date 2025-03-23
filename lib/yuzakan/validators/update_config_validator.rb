# frozen_string_literal: true

require "hanami/validations"

require_relative "../predicates/name_predicates"

class UpdateConfigValidator
  include Hanami::Validations
  predicates NamePredicates
  messages :i18n

  validations do
    optional(:title).filled(:str?, max_size?: 255)
    optional(:domain).maybe(:str?, :domain?, max_size?: 255)
    optional(:session_timeout).filled(:int?, gteq?: 0, lteq?: 24 * 60 * 60)
    optional(:password_min_size).filled(:int?, gteq?: 1, lteq?: 255)
    optional(:password_max_size).filled(:int?, gteq?: 1, lteq?: 255)
    optional(:password_min_score).filled(:int?, gteq?: 0, lteq?: 4)
    optional(:password_prohibited_chars) { str? & password? & max_size?(128) }
    optional(:password_extra_dict) { str? & max_size?(4096) }
    optional(:generate_password_size).filled(:int?, gteq?: 1, lteq?: 255)
    optional(:generate_password_type).filled(:str?)
    optional(:generate_password_chars) { str? & password? & max_size?(128) }
    optional(:contact_name).maybe(:str?, max_size?: 255)
    optional(:contact_email).maybe(:str?, :email?, max_size?: 255)
    optional(:contact_phone).maybe(:str?, max_size?: 255)
  end
end
