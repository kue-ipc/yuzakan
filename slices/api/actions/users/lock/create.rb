# frozen_string_literal: true

module API
  module Actions
    module Users
      module Lock
        class Create < API::Action
          security_level 3

          params do
            required(:user_id).filled(:name, max_size?: 255)
          end

          def initialize(service_repository: ServiceRepository.new,
            **opts)
            super
            @service_repository ||= service_repository
          end

          def handle(_request, _response)
            halt_json 400, errors: [params.errors] unless params.valid?

            result = call_interacttor(ServiceLockUser.new(service_repository: @service_repository),
              {username: params[:user_id]})

            services = result.services.compact.transform_values { |v| {locked: !!v} }
            self.status = 200
            self.body = generate_json({services: services})
          end
        end
      end
    end
  end
end
