# frozen_string_literal: true

module Admin
  module Controllers
    module Session
      class Destroy
        include Admin::Action

        def call(params)
          session[:user_id] = nil
          flash[:successes] = ['ログアウトしました。']
          redirect_to routes.root_path
        end
      end
    end
  end
end
