# frozen_string_literal: true

module Web
  module Controllers
    module Session
      class Destroy
        include Web::Action

        def call(_params)
          session[:user_id] = nil
          session[:access_time] = nil
          flash[:success] = 'ログアウトしました。'
          redirect_to routes.path(:root)
        end
      end
    end
  end
end
