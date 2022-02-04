module Web
  module Controllers
    module Session
      class Destroy
        include Web::Action

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          session[:user_id] = nil
          flash[:success] = 'ログアウトしました。'
          redirect_to routes.path(:root)
        end
      end
    end
  end
end
