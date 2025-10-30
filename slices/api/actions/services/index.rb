# frozen_string_literal: true

module API
  module Actions
    module Services
      class Index < API::Action
        include Deps["repos.service_repo"]

        def handle(_request, response)
          response[:services] = service_repo.all
        end
      end
    end
  end
end
