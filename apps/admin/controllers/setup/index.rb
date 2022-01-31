require 'hanami/action/cache'

module Admin
  module Controllers
    module Setup
      class Index
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store
        security_level 0

        def call(_params)
          redirect_to routes.path(:setup_done) if configurated?
        end

        def configurate!
        end
      end
    end
  end
end
