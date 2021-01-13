require_relative './index'

module Admin
  module Views
    module Providers
      module Params
        class JsonIndex < Index
          format :json

          def render
            raw JSON.generate(provider_params)
          end
        end
      end
    end
  end
end
