# frozen_string_literal: true

module API
  module Actions
    module Adapters
      class Index < API::Action
        include Deps["adapter_repo"]

        def handle(_request, response)
          adapters = adapter_repo.all

          response.format = :json
          response.render(view, adapters:)
        end
      end
    end
  end
end
