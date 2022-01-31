require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Show
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :provider

        params do
          required(:id).filled(:int?)
        end

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super(**opts)
          @provider_repository = provider_repository
        end

        def call(params)
          halt 400 unless params.valid?

          @provider = @provider_repository.find_with_adapter(params[:id])

          halt 404 unless @provider
        end
      end
    end
  end
end
