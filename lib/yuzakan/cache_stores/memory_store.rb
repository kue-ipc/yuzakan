# frozen_string_literal: true

module Yuzakan
  module CacheStores
    class MemoryStore < Yuzakan::CacheStore
      class Value
        attr_reader :data, :expiraiton_time

        def initialize(data, now = Time.now, expire:)
          @data = data
          @expire = expire
          @expiraiton_time = now + expire
        end

        def expired?(now = Time.now)
          now > @expiraiton_time
        end

        def update(data, now = Time.now)
          @data = data
          @expiraiton_time = now + expire
        end
      end

      SEPARATOR = "."

      def initialize(...)
        super
        # ignore namespace
        @stores = Hash.new { |hash, key| hash[key] = {} }
      end

      private def memory_key(key)
        *parents, child = normalize_key(key)
        [parents.join(SEPARATOR), child]
      end

      def key?(key)
        tree, node = memory_key(key)
        @store[tree].key?(node)
      end

      def [](key)
        tree, node = memory_key(key)

        value = @store[tree][node]
        return nil if value.nil?

        if value.expired?
          # expired value
          @store[tree].delete(node)
          return nil
        end

        value.data
      end

      def []=(key, value)
        tree, node = memory_key(key)
        @store[tree][node] = Value.new(value, expire: @expire)
      end

      def delete(key)
        tree, node = memory_key(key)
        value = @store[tree].delete(node)
        return nil if value.nil?
        return nil if value.expired?

        value.data
      end

      def delete_all(key)
        @store.delete_matched("#{redis_key(key)}#{SEPARATOR}*")
      end

      def delete_matched(pattern)
        tree, node = memory_key(key)

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
