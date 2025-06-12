# frozen_string_literal: true

require "yuzakan/utils/array"

module Yuzakan
  module Utils
    module Hash
      def self.deep_transform_keys(hash, &block)
        hash.to_h do |k, v|
          key = block.call(k)
          value =
            case v
            when ::Array
              Yuzakan::Utils::Array.deep_map(v) do |item|
                next item unless item.is_a?(::Hash)

                deep_transform_keys(v, &block)
              end
            when ::Hash
              deep_transform_keys(v, &block)
            else
              v
            end
          [key, value]
        end
      end

      def self.deep_transform_values(hash, &block)
        hash.to_h do |k, v|
          key = k
          value =
            case v
            when ::Array
              Yuzakan::Utils::Array.deep_map(v) do |item|
                next item unless item.is_a?(::Hash)

                deep_transform_values(v, &block)
              end
            when ::Hash
              deep_transform_values(v, &block)
            else
              block.call(v)
            end
          [key, value]
        end
      end

      def self.compact_blank(hash)
        hash.reject do |_k, v|
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def self.deep_merge(first, *others, &block)
        first.merge(*others) do |key, self_val, other_val|
          if self_val.is_a?(Hash) && other_val.is_a?(Hash)
            deep_merge(self_val, other_val, &block)
          elsif block_given?
            block.call(key, self_val, other_val)
          else
            other_val
          end
        end
      end
    end
  end
end
