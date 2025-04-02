# frozen_string_literal: true

module API
  module Actions
    module Session
      class Show < API::Action
        security_level 0
        private def authenticate!(_req, _res) = nil

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          halt_json 404 unless current_user

          self.body = generate_json({
            uuid: session[:uuid],
            current_user: current_user,
            current_level: current_level,
            created_at: session[:created_at],
            updated_at: session[:updated_at],
          })
        end
      end
    end
  end
end
