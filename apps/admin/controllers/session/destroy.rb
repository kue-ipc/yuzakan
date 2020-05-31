# frozen_string_literal: true

module Admin
  module Controllers
    module Session
      class Destroy
        include Admin::Action

        def call(_params)
          session[:user_id] = nil
          session[:access_time] = nil
          flash[:success] = 'ログアウトしました。'
          redirect_to routes.root_path
        end
      end
    end
  end
end
