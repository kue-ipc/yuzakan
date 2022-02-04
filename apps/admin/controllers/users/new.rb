require 'hanami/action/cache'

module Admin
  module Controllers
    module Users
      class New
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :user

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @user = nil
        end
      end
    end
  end
end
