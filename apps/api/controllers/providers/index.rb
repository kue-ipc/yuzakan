# frozen_string_literal: true

module Api
  module Controllers
    module Providers
      class Index
        include Api::Action

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            optional(:has_group).filled(:bool?)
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super
          @provider_repository ||= provider_repository
        end

        def call(params)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          @providers =
            if params[:has_group]
              @provider_repository.ordered_all_group
            else
              @provider_repository.ordered_all
            end

          self.status = 200
          self.body = generate_json(@providers)
        end
      end
    end
  end
end
