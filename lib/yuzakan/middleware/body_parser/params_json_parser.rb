# frozen_string_literal: true

require "hanami/middleware/body_parser/json_parser"

module Yuzakan
  module Middleware
    module BodyParser
      # A custom JSON parser for params of Hanami that transforms keys to snake_case.
      class ParamsJsonParser < Hanami::Middleware::BodyParser::JsonParser
        def parse(...)
          obj = super
          Yuzakan::Utils::Hash.deep_transform_keys(obj) do |key|
            Yuzakan::Utils::String.params_key(key)
          end
        end
      end
    end
  end
end
