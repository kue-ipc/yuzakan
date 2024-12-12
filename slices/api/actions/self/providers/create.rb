# frozen_string_literal: true

module API
  module Actions
    module Self
      module Providers
        class Create < API::Action
          def call(_params)
            self.body = "OK"
          end
        end
      end
    end
  end
end
