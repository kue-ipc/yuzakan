module Api
  module Controllers
    module Session
      class Destroy
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          halt_json 410 unless current_user

          self.status = 200
          self.body = generate_json({
            uuid: session[:uuid],
            current_user: current_user,
            created_at: session[:created_at],
            updated_at: current_time,
            deleted_at: current_time,
          })

          # セッション情報を保存
          session[:user_id] = nil
          session[:created_at] = nil
          session[:updated_at] = nil
        end
      end
    end
  end
end
