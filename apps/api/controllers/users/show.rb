# frozen_string_literal: true

require_relative './set_user'

module Api
  module Controllers
    module Users
      class Show
        include Api::Action
        include SetUser

        security_level 2

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = user_json
        end
      end
    end
  end
end
