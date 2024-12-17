# frozen_string_literal: true

module Yuzakan
  module CacheStores
    class Redis < Yuzakan::CacheStore
      def initialize(namespace:, redis_url:, **)
        super(**)
        @store = Readthis::Cache.new(
          expires_in: @expires_in,
          namespace: namespace,
          redis: {url: redis_url}, dirver: :hiredis)
      end

      def [](...)
        @store.read(...)
      end

      def []=(...)
        @store.write(...)
      end

      def delete(...)
        @store.delete(...)
      end

      def delete_matched(...)
        @store.delete_matched(...)
      end

      def fetch(...)
        @store.fetch(...)
      end

      def clear
        @store.clear
      end
    end
  end
end
