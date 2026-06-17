# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Destroy < API::Action
        include Deps[
          "repos.affiliation_repo",
          view: "views.affiliations.show",
        ]

        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)
          id = take_exist_id(request, response, affiliation_repo)

          affiliation_repo.unset(id)

          response.status = :no_content
        end
      end
    end
  end
end
