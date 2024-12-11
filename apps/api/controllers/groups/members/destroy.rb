# frozen_string_literal: true

module Api
  module Controllers
    module Groups
      module Members
        class Destroy
          include Api::Action

          def call(_params)
            self.body = "OK"
          end
        end
      end
    end
  end
end
