# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Index < API::Action
        include Deps["repos.affiliation_repo"]

        def handle(_request, response)
          response[:affiliations] = affiliation_repo.all
        end
      end
    end
  end
end
