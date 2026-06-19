# auto_register: false
# frozen_string_literal: true

require "date"
require "hanami/utils/json"

module API
  module Views
    module Helpers
      module JSONHelper
        def params_to_json(params)
          obj = Yuzakan::Utils::Hash.deep_transform_values(params) do |value|
            case value
            when nil, true, false, Numeric, String
              value
            when Time, Date
              value.iso8601
            else
              raise "Unsupported value type: #{value.class}"
            end
          end
          json_generate(obj)
        end

        def json_generate(obj)
          Hanami::Utils::Json.generate(obj)
        end
      end
    end
  end
end
