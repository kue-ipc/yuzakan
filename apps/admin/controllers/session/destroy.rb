require 'hanami/action/cache'

module Admin
  module Controllers
    module Session
      class Destroy
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          session[:user_id] = nil
          session[:access_time] = nil
          flash[:success] = 'ログアウトしました。'
          redirect_to routes.path(:root)
        end
      end
    end
  end
end
