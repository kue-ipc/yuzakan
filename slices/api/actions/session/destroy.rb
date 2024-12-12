# frozen_string_literal: true

module Api
  module Actions
    module Session
      class Destroy < API::Action
        security_level 0

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
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
