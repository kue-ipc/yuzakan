module Api
  module Controllers
    module Session
      class Destroy
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          messages = flash.map(&itself).to_h
          result =
            if session[:user_id]
              session[:user_id] = nil

              {
                result: 'success',
                messages: {**messages, success: 'ログアウトしました。'},
                redirect_to: Web.routes.path(:root),
              }
            else
              self.status = 422
              {
                result: 'failure',
                messages: {**messages, failure: 'ログインしていません。'},
              }
            end
          self.body = JSON.generate(result)
        end
      end
    end
  end
end
