require 'time'

module Api
  module Controllers
    module Session
      class Show
        include Api::Action

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = JSON.generate({
            username: current_user.name,
            display_name: current_user.display_name,
            created_at: session[:created_at].iso8601,
            updated_at: session[:updated_at].iso8601,
          })
        end
      end
    end
  end
end
