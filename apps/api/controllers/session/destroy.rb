module Api
  module Controllers
    module Session
      class Destroy
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          unless current_user
            halt 410, JSON.generate({
              code: 410,
              message: 'ログインしていません。',
            })
          end

          session[:user_id] = nil
          self.status = 204
        end
      end
    end
  end
end
