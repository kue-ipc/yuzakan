# frozen_string_literal: true

require "hanami/action/params"
require_relative "../predicates/name_predicates"

class IdParams < Hanami::Action::Params
  predicates NamePredicates
  messages :i18n

  params do
    required(:id).filled(:str?, :name?, max_size?: 255)
  end
end
