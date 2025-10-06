# frozen_string_literal: true

module Yuzakan
  module Operations
    # Convert data between adapter and Ruby types.
    # Ruby data -> Adapter data
    class Map < Yuzakan::Operation
      def call(value, conversion, **params)
        return if value.nil?
        return value if conversion.nil?

        conversion = step verify_conversion(conversion)
        params = step verify_params(params, conversion)

        step map(value, conversion, **params)
      end

      private def map(value, conversion, **_params)
        case conversion
        in "posix_time"
          value.to_time.to_i
        in "posix_date"
          (Date.new(1970, 1, 1) - value.to_date).to_i
        in "path"
          "/#{value}"
        in "e2j"
          translate_j2e(value)
        in "j2e"
          translate_e2j(value)
        else

        end
        case conversion
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
