# frozen_string_literal: true

module Yuzakan
  module Operations
    class Convert < Yuzakan::Operation
      # Adapter data -> Ruby data
      def convert_value(value)
        return if value.nil?

        case conversion
        when nil
          convert_type(value, attr.type)
        when "posix_time"
          Time.at(value.to_i)
        when "posix_date"
          Date.new(1970, 1, 1) + value.to_i
        when "path"
          value.sub(%r{^/+}, "")
        when "e2j"
          translate_e2j(value)
        when "j2e"
          translate_j2e(value)
        else
          value
        end
      end
      alias convert convert_value

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

      # Ruby data -> Adapter data
      def map_value(value)
        return if value.nil?

        return value if conversion.nil?

        case conversion
        when "posix_time"
          value.to_time.to_i
        when "posix_date"
          (Date.new(1970, 1, 1) - value.to_date).to_i
        when "path"
          "/#{value}"
        when "e2j"
          translate_j2e(value)
        when "j2e"
          translate_e2j(value)
        else
          value
        end
      end
      alias reverse_convert map_value

      def translate_e2j(value)
        E2J_DICT[value] || value
      end

      def translate_j2e(value)
        J2E_DICT[value] || value
      end

      def category
        attr.category.intern
      end

      def category_of?(name)
        category.casecmp?(name.intern)
      end

      def readonly
        attr.readonly
      end
    end
  end
end
