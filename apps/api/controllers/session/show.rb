module Api
  module Controllers
    module Session
      class Show
        include Api::Action

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = generate_json({
            username: current_user.name,
            display_name: current_user.display_name,
            created_at: session[:created_at],
            updated_at: session[:updated_at],
            deleted_at: session[:updated_at] + current_config.session_timeout,
          })
        end
      end
    end
  end
end
