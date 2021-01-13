require 'hanami/action/cache'

module Admin
  module Controllers
    module Home
      class Index
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(_params)
          redirect_to routes.path(:dashboard) if authenticated?
        end

        def authenticate!
        end
      end
    end
  end
end
