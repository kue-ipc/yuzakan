# frozen_string_literal: true

module API
  module Actions
    module Services
      class Index < API::Action
        params do
          optional(:has_group).filled(:bool?)
        end

        def initialize(service_repository: ServiceRepository.new, **opts)
          super
          @service_repository ||= service_repository
        end

        def handle(_request, _response)
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          @services =
            if params[:has_group]
              @service_repository.ordered_all_group
            else
              @service_repository.ordered_all
            end

          self.status = 200
          self.body = generate_json(@services)
        end
      end
    end
  end
end
