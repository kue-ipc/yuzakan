# frozen_string_literal: true

require_relative "set_group"

module API
  module Actions
    module Groups
      class Show < API::Action
        include SetGroup

        security_level 2

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          self.body = group_json
        end
      end
    end
  end
end
