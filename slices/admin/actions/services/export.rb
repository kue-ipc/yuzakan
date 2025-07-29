# frozen_string_literal: true

module Admin
  module Actions
    module Services
      class Export < Admin::Action
        security_level 5

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def initialize(service_repository: ServiceRepository.new, **)
          super(**)
          @service_repository = service_repository
        end

        def handle(_request, _response)
          halt 400 unless params.valid?
          @name = params[:id].to_s
          @service = @service_repository.find_with_params_by_name(@name)
          halt 404 unless @service
          halt 403 unless @service.adapter == "local"
        end
      end
    end
  end
end
