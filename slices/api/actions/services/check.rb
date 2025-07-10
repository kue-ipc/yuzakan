# frozen_string_literal: true

module API
  module Actions
    module Services
      class Check < API::Action
        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body = generate_json({check: @service.check})
        end
      end
    end
  end
end
