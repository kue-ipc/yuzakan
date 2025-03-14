# frozen_string_literal: true

require_relative "entity_group"

module API
  module Actions
    module Groups
      module SetGroup
        include EntityGroup

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        def self.included(action)
          action.class_eval do
            params Params
            before :set_group
          end
        end

        private def set_group
          halt_json 400, errors: [params.errors] unless params.valid?

          @name = params[:id]
          load_group

          halt_json 404 if @group.nil?
        end
      end
    end
  end
end
