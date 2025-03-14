# frozen_string_literal: true

require_relative "entity_user"

module API
  module Actions
    module Users
      module SetUser
        include EntityUser

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
            before :set_user
          end
        end

        private def set_user
          halt_json 400, errors: [params.errors] unless params.valid?

          @name = params[:id]
          load_user

          halt_json 404 if @user.nil?
        end
      end
    end
  end
end
