# frozen_string_literal: true

module Yuzakan
  module Actions
    module Password
      class Edit < Yuzakan::Action
        include Deps[
          "repos.provider_repo",
        ]

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          response[:excluded_providers] = provider_repo.all_individual_password
        end
      end
    end
  end
end
