# frozen_string_literal: true

require_relative "set_user"

module API
  module Actions
    module Users
      class Show < API::Action
        include SetUser

        security_level 2

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          self.body = user_json
        end
      end
    end
  end
end
