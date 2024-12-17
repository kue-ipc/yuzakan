# frozen_string_literal: true

module Yuzakan
  module CacheStores
    class Memory < Yuzakan::CacheStore
      def initialize(...)
        super
        @store = {}
      end

      def [](key)
        return nil unless @store.key?(key)

        time, value = @store[key]
        if Time.now - time >= @expires_in
          @store.delete(key)
          return nil
        end

        value
      end

      def []=(key, value)
        @store[key] = [Time.now, value]
      end

      def delete(key)
        @store.delete(key)
      end

      def delete_matched(pattern)
        # TODO: プリフィックスのみ
        prefix = pattern.split(/\*|\?|\[/).first
        @store.delete_if { |key, _value| key.start_with?(prefix) }
      end

      def fetch(key, &)
        if @store.key?(key)
          time, value = @store[key]
          return value if Time.now - time <= @expires_in

          @store.delete(key)
        end

        yield key
      end

      def clear
        @store.clear
      end
    end
  end
end
