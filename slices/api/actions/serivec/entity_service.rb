# frozen_string_literal: true

module API
  module Actions
    module Services
      module EntityService
        def initialize(service_repository: ServiceRepository.new,
          **opts)
          super
          @service_repository ||= service_repository
        end

        private def load_service
          @service = @service_repository.find_with_params_by_name(@name)
        end

        private def service_json
          generate_json(@service, assoc: current_level >= 5)
        end
      end
    end
  end
end
