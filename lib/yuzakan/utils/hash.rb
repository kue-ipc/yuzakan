# frozen_string_literal: true

require "yuzakan/utils/array"

module Yuzakan
  module Utils
    module Hash
      def self.deep_transform_keys(obj, &block)
        obj.to_h do |k, v|
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

      def self.deep_transform_values(obj, &block)
        obj.to_h do |k, v|
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

      def self.compact_blank(obj)
        obj.reject do |_k, v|
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end
    end
  end
end
