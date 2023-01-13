# frozen_string_literal: true

require 'hanami/validations'
require_relative '../predicates/name_predicates'
require_relative '../entities/attr_mapping'

class AttrMappingValidator
  include Hanami::Validations
  predicates NamePredicates
  messages :i18n

  validations do
    required(:provider).filled(:str?, :name?, max_size?: 255)
    required(:name).maybe(:str?, max_size?: 255)
    optional(:conversion) { none? | included_in?(AttrMapping::CONVERSIONS) }
  end
end
