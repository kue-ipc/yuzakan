# frozen_string_literal: true

require_relative "set_provider"

module API
  module Actions
    module Providers
      class Check < API::Action
        include SetProvider

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body = generate_json({check: @provider.check})
        end
      end
    end
  end
end
