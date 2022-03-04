module Api
  module Controllers
    module Session
      class Destroy
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          halt_json 410 unless current_user

          session[:user_id] = nil
          self.status = 204
        end
      end
    end
  end
end
