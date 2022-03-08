module Api
  module Controllers
    module Session
      class Show
        include Api::Action

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = generate_json({
            uuid: session[:uuid],
            current_user: current_user,
            created_at: session[:created_at],
            updated_at: session[:updated_at],
            deleted_at: session[:updated_at] + current_config.session_timeout,
          })
        end
      end
    end
  end
end
