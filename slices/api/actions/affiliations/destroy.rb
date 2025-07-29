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

        def handle(request, response)
          affiliation = affiliation_repo.get(request.params[:id].to_s)
          halt_json request, response, 404 if affiliation.nil?

          affiliation_repo.unset(affiliation.name)

          response[:affiliation] = affiliation
          response.render(show_view)
        end
      end
    end
  end
end
