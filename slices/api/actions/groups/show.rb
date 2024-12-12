# frozen_string_literal: true

require_relative "set_group"

module Api
  module Actions
    module Groups
      class Show < API::Action
        include SetGroup

        security_level 2

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.body = group_json
        end
      end
    end
  end
end
