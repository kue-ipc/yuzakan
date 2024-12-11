# frozen_string_literal: true

require "hanami/validations"

require_relative "../predicates/name_predicates"
require_relative "../entities/attr"

require_relative "create_attr_mapping_validator"

class CreateAttrValidator
  include Hanami::Validations
  predicates NamePredicates
  messages :i18n

  validations do
    required(:name).filled(:str?, :name?, max_size?: 255)
    optional(:display_name).maybe(:str?, max_size?: 255)
    required(:type).filled(:str?, included_in?: Attr::TYPES)
    optional(:order).filled(:int?)
    optional(:hidden).filled(:bool?)
    optional(:readonly).filled(:bool?)
    optional(:code).maybe(:str?, max_size?: 4096)
    optional(:description).maybe(:str?, max_size?: 4096)
    optional(:attr_mappings).each(schema: CreateAttrMappingValidator)
  end
end
