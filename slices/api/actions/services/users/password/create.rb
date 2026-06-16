# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Password
          class Create < API::Action
            def handle(request, response)
              response.body = self.class.name
            end
          end
        end
      end
    end
  end
end
