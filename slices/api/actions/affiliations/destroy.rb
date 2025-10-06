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
          check_params(request, response)
          check_exist_id(request, response, affiliation_repo)

          affiliation = affiliation_repo.unset(request.params[:id])

          response[:affiliation] = affiliation
          response.render(show_view)
        end
      end
    end
  end
end
