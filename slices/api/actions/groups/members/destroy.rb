# frozen_string_literal: true

module API
  module Actions
    module Groups
      module Members
        class Destroy < API::Action
          def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
            self.body = "OK"
          end
        end
      end
    end
  end
end
