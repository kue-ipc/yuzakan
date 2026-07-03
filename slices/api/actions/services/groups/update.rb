# frozen_string_literal: true

module API
  module Actions
    module Services
      module Groups
        class Update < API::Action
          def handle(_request, response)
            response.body = self.class.name
          end
        end
      end
    end
  end
end
