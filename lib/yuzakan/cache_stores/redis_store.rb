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

      private def redis_key(key)
        normalize_key(key).join(SEPARATOR)
      end

      def key?(key)
        @store.exist?(redis_key(key))
      end

      def [](key)
        @store.read(redis_key(key))
      end

      def []=(key, value)
        @store.write(redis_key(key), value)
        value
      end

      def delete(key)
        value = self[key]
        @store.delete(redis_key(key))
        value
      end

      def delete_all(key)
        @store.delete_matched("#{redis_key(key)}#{SEPARATOR}*")
      end

      def clear
        @store.clear
        self
      end

      def fetch(key, &)
        @store.fetch(redis_key(key), &)
      end
    end
  end
end
