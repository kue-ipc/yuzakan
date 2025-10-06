# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Destroy < API::Action
        include Deps[
          "repos.affiliation_repo",
          show_view: "views.affiliations.show"
        ]

        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params_validation(request, response)
          affiliation = get_by_id(request, response, affiliation_repo)

          affiliation_repo.unset(affiliation.name)

          response[:affiliation] = affiliation
          response.render(show_view)
        end
      end
    end
  end
end
