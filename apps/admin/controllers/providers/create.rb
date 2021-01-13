require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Create
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          result = UpdateProvider.new.call(params[:provider])

          if result.failure?
            flash[:errors] = result.errors
            redirect_to routes.path(:new_provider)
          end

          redirect_to routes.path(:providers)
        end
      end
    end
  end
end
