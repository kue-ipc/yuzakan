# frozen_string_literal: true

module API
  module Actions
    module Services
      module Groups
        class Destroy < API::Action
          def handle(request, response)
            response.body = self.class.name
          end
        end
      end
    end
  end
end
