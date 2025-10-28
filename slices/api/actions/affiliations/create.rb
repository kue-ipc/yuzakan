# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Create < API::Action
        include Deps[
          "repos.affiliation_repo",
          show_view: "views.affiliations.show"
        ]

        security_level 4

        params do
          required(:name).filled(:name, max_size?: 255)
          optional(:label).value(:str?, max_size?: 255)
          optional(:note).value(:str?, max_size?: 4096)
        end

        def handle(request, response)
          check_params(request, response)
          name = take_unique_name(request, response, affiliation_repo)

          affiliation = affiliation_repo.set(name, **request.params)

          response.status = :created
          response.headers["Content-Location"] = "/api/affiliations/#{name}"
          response[:location] = "/api/affiliations/#{name}"
          response[:affiliation] = affiliation
          response.render(show_view)
        end
      end
    end
  end
end
