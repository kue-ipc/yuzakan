# frozen_string_literal: true

module Api
  module Actions
    module Session
      class Show < API::Action
        security_level 0

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          halt_json 404 unless current_user

          self.body = generate_json({
            uuid: session[:uuid],
            current_user: current_user,
            current_level: current_level,
            created_at: session[:created_at],
            updated_at: session[:updated_at],
            deleted_at: session[:updated_at] + current_config.session_timeout,
          })
        end
      end
    end
  end
end
