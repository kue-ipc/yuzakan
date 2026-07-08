# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Destroy < API::Action
        include Deps[
          "repos.group_repo",
          view: "views.groups.show",
        ]

        security_level 4

        contract Validation::IdContract

        def handle(request, response)
          check_params(request, response)
          id = take_exist_id(request, response, group_repo)

          group = group_repo.unset(id)

          response[:group] = group
        end
      end
    end
  end
end
