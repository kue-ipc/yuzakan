# frozen_string_literal: true

module API
  module Actions
    module Adapters
      class Index < API::Action
        include Deps["adapter_repo"]

        def handle(_request, response)
          response[:adapters] = adapter_repo.all
        end
      end
    end
  end
end
