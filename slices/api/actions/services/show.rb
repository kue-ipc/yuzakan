# frozen_string_literal: true

module API
  module Actions
    module Services
      class Show < API::Action
        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          private def set_service
            unless params.valid?
              halt_json 400,
                errors: [only_first_errors(params.errors)]
            end

            @name = params[:id]
            load_service

            halt_json 404 if @service.nil?
          end

          self.status = 200
          self.body = service_json
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
