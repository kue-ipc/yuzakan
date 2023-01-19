# frozen_string_literal: true

module Api
  module Controllers
    module Self
      module Providers
        module Lock
          class Destroy
            include Api::Action

            def call(_params)
              self.body = 'OK'
            end
          end
        end
      end
    end
  end
end
