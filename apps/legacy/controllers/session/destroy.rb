# frozen_string_literal: true

module Legacy
  module Controllers
    module Session
      class Destroy
        include Legacy::Action

        def call(_params)
          session[:user_id] = nil
          flash[:success] = 'ログアウトしました。'
          redirect_to routes.root_path
        end
      end
    end
  end
end
