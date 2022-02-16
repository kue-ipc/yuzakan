module Api
  module Controllers
    module Session
      class Destroy
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          result =
            if session[:user_id]
              session[:user_id] = nil

              {
                result: 'success',
                message: 'ログアウトしました。',
              }
            else
              self.status = 410
              {
                result: 'error',
                message: 'ログインしていません。',
              }
            end
          self.body = JSON.generate(result)
        end
      end
    end
  end
end
