module Api
  module Controllers
    module Session
      class Destroy
        include Api::Action

        def call(_params)
          session[:user_id] = nil

          @result = {
            result: 'success',
            messages: {success: 'ログアウトしました。'},
            redirect_to: Web.routes.path(:root),
          }
        end
      end
    end
  end
end
