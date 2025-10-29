# frozen_string_literal: true

module API
  module Actions
    module Adapters
      class Index < API::Action
        include Deps["adapter_map"]

        def handle(request, response)
          response[:adapters] = adapter_map.values
        end
      end
    end
  end
end
