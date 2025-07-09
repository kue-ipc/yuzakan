# frozen_string_literal: true

require_relative "set_service"

module API
  module Actions
    module Services
      class Show < API::Action
        include SetService

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body = service_json
        end
      end
    end
  end
end
