# frozen_string_literal: true

module API
  module Actions
    module Services
      class Show < API::Action
        include Deps["repos.service_repo"]

        params do
          required(:id) { filled(:name, max_size?: 255) }
        end

        def handle(request, response)
          check_params(request, response)

          id = take_exist_id(request, response, service_repo)
          service = service_repo.get(id)

          response[:service] = service
        end
      end
    end
  end
end
