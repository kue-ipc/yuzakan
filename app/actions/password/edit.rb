# frozen_string_literal: true

module Yuzakan
  module Actions
    module Password
      class Edit < Yuzakan::Action
        include Deps[
          "repos.service_repo"
        ]

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          response[:excluded_services] = service_repo.all_individual_password
        end
      end
    end
  end
end
