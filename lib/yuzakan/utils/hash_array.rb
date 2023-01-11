# frozen_string_literal: true

# HashとArrayに関するユーティリティー

module Yuzakan
  module Utils
    module HashArray
      module_function # rubocop:disable Stlye/AccessModifierDeclarations

      # HashのArrayに対して、同じキーの場合に一つにまとめる
      def ha_merge(harr, key:, delete_key: :delete)
        data = {}

        harr.each do |hash|
          key_value = hash[key]

          next if key_value.nil?

          if hash[delete_key]
            data.delete(key_value) if data.key?(key_value)
          else
            data[key_value] = (data[key_value] || {}).merge(hash)
          end
        end
        data.values
      end

      def deep_freeze(obj)
        case obj
        when Array
          obj.each do |v|
            deep_freeze(v)
          end
        when Hash
          obj.each do |k, v|
            deep_freeze(k)
            deep_freeze(v)
          end
        end
        obj.freeze
      end

      def deep_merge(*objs)
        if objs.empty?
          nil
        elsif objs.size == 1
          objs[0]
        else
          objs[0].merge(*objs[1..]) do |key, self_val, other_val|
            if self_val.is_a?(Hash) && other_val.is_a?(Hash)
              deep_merge(self_val, other_val)
            elsif block_given?
              yield key, self_val, other_val
            else
              other_val
            end
          end
        end
      end

      def stringify_keys(obj)
        case obj
        when Array
          obj.map { |v| stringify_keys(v) }
        when Hash
          obj.transform_keys(&:to_s).transform_values { |v| stringify_keys(v) }
        else
          obj
        end
      end

      def symbolize_keys(obj)
        case obj
        when Array
          obj.map { |v| symbolize_keys(v) }
        when Hash
          obj.transform_keys(&:intern).transform_values { |v| symbolize_keys(v) }
        else
          obj
        end
      end
    end
  end
end
