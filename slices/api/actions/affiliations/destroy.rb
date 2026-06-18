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
          required(:id).filled(:name, max_size?: MAX_STRING_SIZE)
        end

        def handle(request, response)
          check_params(request, response)

          name = request.params[:id]

          affiliation_repo.unset!(name)

          response.status = :no_content
        end
      end
    end
  end
end
