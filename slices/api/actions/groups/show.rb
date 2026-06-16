# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Show < API::Action
        include Deps[
          "repos.service_repo",
          "repos.group_repo",
        ]

        security_level 2

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)

          id = take_exist_id(request, response, group_repo)
          group = group_repo.get(id)
          response[:group] = group
        end
      end
    end
  end
end
