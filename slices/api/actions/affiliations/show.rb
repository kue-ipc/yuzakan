# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Show < API::Action
        include Deps[
          "repos.affiliation_repo"
        ]

        security_level 1

        def handle(request, response)
          affiliation = affiliation_repo.get(request.params[:id].to_s)
          halt_json request, response, 404 if affiliation.nil?

          response[:affiliation] = affiliation
        end
      end
    end
  end
end
