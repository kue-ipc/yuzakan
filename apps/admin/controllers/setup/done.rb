require 'hanami/action/cache'

module Admin
  module Controllers
    module Setup
      class Done
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store
        security_level 0

        def call(params)
        end
      end
    end
  end
end
