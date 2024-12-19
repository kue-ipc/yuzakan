# frozen_string_literal: true

module Yuzakan
  module CacheStores
    class RedisStore < Yuzakan::CacheStore
      SEPARATOR = ":"

      def initialize(redis_url:, **)
        super(**)
        @store = Readthis::Cache.new(
          expires_in: @expire,
          namespace: redis_key(@namespace),
          redis: {url: redis_url},
          dirver: :hiredis)
      end

      def key?(key)
        @store.exist?(key)
      end

      def [](key)
        @store.read(key)
      end

      def []=(key, value)
        @store.write(key, value)
        value
      end

      def delete(key)
        value = self[key]
        @store.delete(key)
        value
      end

      def delete_all(key)
        @store.delete_matched("#{key}#{SEPARATOR}*")
      end

      def clear
        @store.clear
        self
      end

      def fetch(key, &)
        @store.fetch(key, &)
      end
    end
  end
end
