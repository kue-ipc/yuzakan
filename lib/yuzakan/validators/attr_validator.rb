# frozen_string_literal: true

require 'hanami/validations'
require_relative '../predicates/name_predicates'
require_relative './attr_mapping_validator'

class AttrValidator
  include Hanami::Validations
  predicates NamePredicates
  messages :i18n

  validations do
    required(:name).filled(:str?, :name?, max_size?: 255)
    optional(:display_name).maybe(:str?, max_size?: 255)
    required(:type).filled(:str?)
    optional(:hidden).filled(:bool?)
    optional(:readonly).filled(:bool?)
    optional(:code).maybe(:str?, max_size?: 4096)
    optional(:attr_mappings) { array? { each { schema {
      predicates NamePredicates
      required(:provider).filled(:str?, :name?, max_size?: 255)
      required(:name).maybe(:str?, max_size?: 255)
      optional(:conversion) { none? | included_in?(AttrMapping::CONVERSIONS) }
    } } } }
required(:id).filled(:str?, :name?, max_size?: 255)
  end
end
