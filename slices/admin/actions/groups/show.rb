# frozen_string_literal: true

module Admin
  module Actions
    module Groups
      class Show < Admin::Action
        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def handle(_req, _res)
          halt 400 unless params.valid?
        end
      end
    end
  end
end
