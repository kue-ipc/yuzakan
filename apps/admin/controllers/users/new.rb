require 'hanami/action/cache'

module Admin
  module Controllers
    module Users
      class New
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :user

        def call(_params)
          @user = nil
        end
      end
    end
  end
end
