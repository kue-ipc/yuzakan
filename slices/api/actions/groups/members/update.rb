# frozen_string_literal: true

module API
  module Actions
    module Groups
      module Members
        class Update < API::Action

          def call(_params)
            self.body = "OK"
          end
        end
      end
    end
  end
end
