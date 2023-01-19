# frozen_string_literal: true

module Api
  module Controllers
    module Providers
      module Myself
        class Show
          include Api::Action

          def call(_params)
            self.body = 'OK'
          end
        end
      end
    end
  end
end
