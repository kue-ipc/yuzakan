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
        value = @store[tree][node]
        return false if value.nil?

        if value.expired?
          # expired value
          @store[tree].delete(node)
          return false
        end

        true
      end

      def [](key)
        tree, node = memory_key(key)
        value = @store[tree][node]
        return if value.nil?

        if value.expired?
          # expired value
          @store[tree].delete(node)
          return
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
        return if value.nil?
        return if value.expired?

        value.data
      end

      def delete_all(key)
        tree = normalize_key(key).join(SEPARATOR)
        count = @store[tree].each_value.count { |value| !value.expired? }
        @store[tree].clear
        count
      end

      def fetch(key)
        tree, node = memory_key(key)
        value = @store[tree][node]
        return yield key if value.nil?

        if value.expired?
          # expired value
          @store[tree].delete(node)
          return yield key
        end

        value.data
      end

      def clear
        @store.clear
      end
    end
  end
end
