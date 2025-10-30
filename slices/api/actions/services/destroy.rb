# frozen_string_literal: true

module API
  module Actions
    module Services
      class Destroy < API::Action
        include Deps[
          "repos.service_repo",
          show_view: "views.services.show"
        ]

        security_level 5

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)

          id = take_exist_id(request, response, service_repo)
          service = service_repo.unset(id)

          response[:service] = service
          response.render(show_view)
        end
      end
    end
  end
end
