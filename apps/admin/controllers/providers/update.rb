require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Update
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          provider = ProviderRepository.new.find(params[:id])
          result = UpdateProvider.new(provider: provider)
            .call(params[:provider])

          if result.failure?
            flash[:errors] = result.errors
            redirect_to routes.path(:edit_provider, provider.id)
          end

          redirect_to routes.path(:providers)
        end
      end
    end
  end
end
