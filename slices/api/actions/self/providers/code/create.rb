# frozen_string_literal: true

module Api
  module Actions
    module Self
      module Providers
        module Code
          class Create
            include Api::Action

            def call(_params)
              self.body = "OK"
            end
          end
        end
      end
    end
  end
end
