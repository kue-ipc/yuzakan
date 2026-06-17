# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Update < API::Action
        include Deps[
          "repos.affiliation_repo",
          view: "views.affiliations.show",
        ]

        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)

          optional(:name).filled(:name, max_size?: 255)
          optional(:label).value(:str?, max_size?: 255)
          optional(:note).value(:str?, max_size?: 4096)
        end

        def handle(request, response)
          check_params(request, response)
          id = take_exist_id(request, response, affiliation_repo)
          name = take_unique_name(request, response, affiliation_repo)

          affiliation = affiliation_repo.set(id, **request.params)

          response.fresh last_modified: affiliation.updated_at
          response.format = :json
          response.render(view, affiliation:)
        end
      end
    end
  end
end
