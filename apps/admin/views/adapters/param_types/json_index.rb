module Admin
  module Views
    module Adapters
      module ParamTypes
        class JsonIndex < Index
          format :json

          def render
            raw JSON.generate(param_types)
          end
        end
      end
    end
  end
end
