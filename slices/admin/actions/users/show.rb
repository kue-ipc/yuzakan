# frozen_string_literal: true

module Admin
  module Actions
    module Users
      class Show < Admin::Action
        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name_or_star?, max_size?: 255)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new, **opts)
          super
          @user_repository ||= user_repository
        end

        def handle(_request, _response)
          halt 400 unless params.valid?
        end
      end
    end
  end
end
