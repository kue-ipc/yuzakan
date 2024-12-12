# frozen_string_literal: true

module Admin
  module Actions
    module Providers
      class Show < Admin::Action
        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name_or_star?, max_size?: 255)
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new, **)
          super(**)
          @provider_repository = provider_repository
        end

        def handle(_request, _response)
          halt 400 unless params.valid?
          name = params[:id].to_s
          halt 404 unless name == "*" || @provider_repository.exist_by_name?(name)
        end
      end
    end
  end
end
