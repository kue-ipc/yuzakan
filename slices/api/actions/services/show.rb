# frozen_string_literal: true

module API
  module Actions
    module Services
      class Show < API::Action
        include Deps["repos.service_repo"]

        contract do
          params do
            required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)
          end

          rule(:id).validate(:name)
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
