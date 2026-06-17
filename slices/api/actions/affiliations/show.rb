# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Show < API::Action
        include Deps["repos.affiliation_repo"]

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)

          id = take_exist_id(request, response, affiliation_repo)
          affiliation = affiliation_repo.get(id)

          response.fresh last_modified: affiliation.updated_at
          response.format = :json
          response.render(view, affiliation:)
        end
      end
    end
  end
end
