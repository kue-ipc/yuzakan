# frozen_string_literal: true

require "hanami/validations"

require_relative "../predicates/name_predicates"

class CreateProviderValidator
  include Hanami::Validations
  predicates NamePredicates
  messages :i18n

  validations do
    required(:name).filled(:str?, :name?, max_size?: 255)
    optional(:display_name).maybe(:str?, max_size?: 255)
    required(:adapter).filled(:str?, :name?, max_size?: 255)
    optional(:order).filled(:int?)
    optional(:readable).filled(:bool?)
    optional(:writable).filled(:bool?)
    optional(:authenticatable).filled(:bool?)
    optional(:password_changeable).filled(:bool?)
    optional(:lockable).filled(:bool?)
    optional(:individual_password).filled(:bool?)
    optional(:self_management).filled(:bool?)
    optional(:group).filled(:bool?)
    optional(:params) { hash? }
  end
end
