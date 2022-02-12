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
                errors: [*flash[errors]],
              }
            else
              self.status = 422
              {
                result: 'failure',
                message: 'ログインしていません。',
                errors: [*flash[errors]],
              }
            end
          self.body = JSON.generate(result)
        end
      end
    end
  end
end
