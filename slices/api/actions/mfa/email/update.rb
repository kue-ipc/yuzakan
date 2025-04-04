# frozen_string_literal: true

module API
  module Actions
    module Mfa
      module Email
        class Update < API::Action
          security_level 0
          required_trusted_authentication false

          def handle(request, response)
          end
        end
      end
    end
  end
end
