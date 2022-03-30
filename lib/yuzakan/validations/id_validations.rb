require 'hanami/validations'
require_relative '../predicates/name_predicates'

class IdValidations
  include Hanami::Validations
  predicates NamePredicates
  messages :i18n

  validations do
    required(:id).filled(:str?, :name?, max_size?: 255)
  end
end
