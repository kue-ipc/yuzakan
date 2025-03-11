# frozen_string_literal: true

require_relative "set_provider"

module API
  module Actions
    module Providers
      class Show < API::Action
        include SetProvider

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body = provider_json
        end
      end
    end
  end
end
