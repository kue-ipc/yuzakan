# frozen_string_literal: true

module Yuzakan
  module Operations
    # Convert data between adapter and Ruby types.
    # Adapter data -> Ruby data
    class Convert < Yuzakan::Operation
      def call(value, conversion = nil, **params)
        conversion = step verify_conversion(conversion)
        params = step verify_params(params, conversion)

        value = step map(value, conversion, **params)
        value
      end

      private def convert(value, conversion, **params)

        return if value.nil?
        return value if conversion.nil?

        case conversion
        in nil
          convert_type(value, attr.type)
        in "posix_time"
          Time.at(value.to_i)
        in "posix_date"
          Date.new(1970, 1, 1) + value.to_i
        in "path"
          value.sub(%r{^/+}, "")
        in "e2j"
          translate_e2j(value)
        in "j2e"
          translate_j2e(value)
        end
      end

      private def convert_type(value, type)
        case type
        when "boolean"
          if TRUE_VALUES.include?(value)
            true
          elsif FALSE_VALUES.include?(value)
            false
          end
        when "string"
          value.to_s
        when "integer"
          value.to_i
        when "float"
          value.to_f
        when "date"
          value.to_date
        when "time", "datetime"
          value.to_time
        else
          value
        end
      end

    end
  end
end
