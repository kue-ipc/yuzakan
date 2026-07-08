# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        class Show < API::Action
          contract Validation::CurrentUserServiceContract

          def handle(request, response)
          end
        end
      end
    end
  end
end
