# frozen_string_literal: true

module Api
  module Actions
    module Groups
      module Members
        class Update
          include Api::Action

          def call(_params)
            self.body = "OK"
          end
        end
      end
    end
  end
end
