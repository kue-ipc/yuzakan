# auto_register: false
# frozen_string_literal: true

require "hanami/utils/json"

module API
  module Views
    module Helpers
      module JSONHelper
        def params_to_json(params)
          obj =
            Yuzakan::Utils::Hash.deep_transform_keys(params) do |key|
              Yuzakan::Utils::String.json_key(key)
            end
          Hanami::Utils::Json.generate(obj)
        end
      end
    end
  end
end
