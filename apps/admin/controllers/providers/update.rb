# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Update
        include Admin::Action

        def call(params)
          provider = ProviderRepository.new.find(params[:id])
          result = UpdateProvider.new(provider: provider)
            .call(params[:provider])

          if result.failure?
            flash[:errors] = result.errors
            redirect_to routes.path(:edit_provider, provider: provider)
          end

          redirect_to routes.path(:providers)
        end
      end
    end
  end
end
