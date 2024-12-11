# frozen_string_literal: true

require "hanami/validations"

require_relative "../predicates/name_predicates"

class IdValidator
  include Hanami::Validations
  predicates NamePredicates
  messages :i18n

  validations do
    required(:id).filled(:str?, :name?, max_size?: 255)
  end
end
