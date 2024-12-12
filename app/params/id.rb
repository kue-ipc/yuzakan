# frozen_string_literal: true

module Yuzakan
  module Params
    class Id < Hanami::Action::Params
      predicates NamePredicates
      messages :i18n

      params do
        required(:id).filled(:str?, :name?, max_size?: 255)
      end
    end
  end
end
