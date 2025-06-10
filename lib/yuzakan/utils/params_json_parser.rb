# frozen_string_literal: true

require "hanami/middleware/body_parser/json_parser"
require "hanami/utils/string"

module Yuzakan
  module Utils
    # A custom JSON parser for params of Hanami that transforms keys to snake_case.
    class ParamsJsonParser < Hanami::Middleware::BodyParser::JsonParser
      def parse(...)
        obj = super
        deep_transform_keys(obj) { |key| Hanami::Utils::String.underscore(key.to_s) }
      end
      private def deep_transform_keys(obj, &block)
        case obj
        when Hash
          obj.to_h { |k, v| [block.call(k), deep_transform_keys(v, &block)] }
        when Array
          obj.map { |v| deep_transform_keys(v, &block) }
        else
          obj
        end
      end
    end
  end
end
