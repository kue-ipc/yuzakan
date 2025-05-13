# frozen_string_literal: true

module API
  module Actions
    module Config
      class Show < API::Action
        def handle(_request, response)
          response[:config] = response[:current_config]
        end
      end
    end
  end
end
