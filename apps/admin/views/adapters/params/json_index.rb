# frozen_string_literal: true

require_relative './index'

module Admin
  module Views
    module Adapters
      module Params
        class JsonIndex < Index
          format :json

          def render
            raw JSON.generate(adapter.params)
          end
        end
      end
    end
  end
end
