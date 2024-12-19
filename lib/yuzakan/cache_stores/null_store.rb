# frozen_string_literal: true

module Yuzakan
  module CacheStores
    class NullStore < Yuzakan::CacheStore
      def key?(_key) = false

      def [](_key) = nil

      def []=(_key, value)
        value
      end

      def delete(_key) = nil

      def delete_all(_key) = 0

      def clear = self
    end
  end
end
