# frozen_string_literal: true

module Yuzakan
  module CacheStores
    class Null < Yuzakan::CacheStore
      def [](key)
      end

      def []=(key, value)
      end

      def delete(key)
      end

      def delete_matched(pattern)
      end

      def fetch(key, default = nil)
        if block_given?
          yield key
        else
          default
        end
      end

      def clear
        self
      end
    end
  end
end
