# frozen_string_literal: true

require_relative "set_service"

module API
  module Actions
    module Services
      class Destroy < API::Action
        include SetService

        security_level 5

        def initialize(service_repository: ServiceRepository.new, **opts)
          super
          @service_repository ||= service_repository
        end

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          @service_repository.delete(@service.id)

          self.status = 200
          self.body = service_json
        end
      end
    end
  end
end
