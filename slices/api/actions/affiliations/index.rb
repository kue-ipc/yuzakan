# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Index < API::Action
        include Deps[
          "repos.affiliation_repo"
        ]

        security_level 1

        def handle(_request, response)
          affiliations = affiliation_repo.all
          response[:affiliations] = affiliations
        end
      end
    end
  end
end
