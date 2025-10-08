# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Index < API::Action
        include Deps["repos.affiliation_repo"]

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          affiliations = affiliation_repo.all
          response[:affiliations] = affiliations
        end
      end
    end
  end
end
