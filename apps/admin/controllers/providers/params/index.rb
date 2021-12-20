require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      module Params
        class Index
          include Admin::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :provider
          expose :provider_params

          def call(params)
            @provider = ProviderRepository.new.find_with_adapter(params[:provider_id])
            @provider_params = @provider.safe_params
          end
        end
      end
    end
  end
end
