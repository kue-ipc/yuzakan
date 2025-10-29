# frozen_string_literal: true

module API
  module Actions
    module System
      class Show < API::Action
        security_level 0
        required_authentication false
        required_configuration false

        def handle(request, response)
        end
      end
    end
  end
end
