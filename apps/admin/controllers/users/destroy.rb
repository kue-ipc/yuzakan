require 'hanami/action/cache'

module Admin
  module Controllers
    module Users
      class Destroy
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
        end
      end
    end
  end
end
