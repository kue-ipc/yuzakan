# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        class Update < API::Action
          contract Validation::UserServiceContract

          def handle(_request, response)
            response.body = self.class.name
          end
        end
      end
    end
  end
end
