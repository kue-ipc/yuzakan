# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Show < API::Action
        include Deps[
          "repos.affiliation_repo"
        ]

        security_level 1

        params do
          required(:id) { filled(:name, max_size?: 255) | eql?("~") }
        end

        def handle(request, response)
          check_params_validation(request, response)

          affiliation =
            if request.params[:id] == "~"
              affiliation_repo.find(response[:current_user].affiliation_id)
            else
              get_by_id(request, response, affiliation_repo)
            end

          response[:affiliation] = affiliation
        end
      end
    end
  end
end
