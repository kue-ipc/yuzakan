# frozen_string_literal: true

require_relative "set_group"

module Api
  module Controllers
    module Groups
      class Show
        include Api::Action
        include SetGroup

        security_level 2

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = group_json
        end
      end
    end
  end
end
