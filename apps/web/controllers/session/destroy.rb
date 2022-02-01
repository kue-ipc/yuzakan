module Web
  module Controllers
    module Session
      class Destroy
        include Web::Action

        def call(_params)
          session[:user_id] = nil
          flash[:success] = 'ログアウトしました。'
          redirect_to routes.path(:root)
        end
      end
    end
  end
end
