# frozen_string_literal: true

module API
  module Actions
    module Self
      module Providers
        class Show < API::Action

          def call(_params)
            self.body = "OK"
          end
        end
      end
    end
  end
end
