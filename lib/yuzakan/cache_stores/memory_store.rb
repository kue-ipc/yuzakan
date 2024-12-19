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

      def initialize(...)
        super
        # ignore namespace
        @stores = Hash.new { |hash, key| hash[key] = {} }
      end

      def key?(key)
        tree, node = take_key(key)
        cache = @store[tree][node]
        return false if cache.nil?

        if cache.expired?
          # expired value
          @store[tree].delete(node)
          return false
        end

        true
      end

      def [](key)
        tree, node = take_key(key)
        cache = @store[tree][node]
        return if cache.nil?

        if cache.expired?
          # expired value
          @store[tree].delete(node)
          return
        end

        value.data
      end

      def []=(key, value)
        tree, node = take_key(key)
        cache = @store[tree][node]
        if cache
          cache.update(value)
        else
          @store[tree][node] = Value.new(value, expire: @expire)
        end
        value
      end

      def delete(key)
        tree, node = take_key(key)
        cache = @store[tree].delete(node)
        return if cache.nil?
        return if cache.expired?

        cache.data
      end

      def delete_all(key)
        count = @store[key].each_value.count { |value| !value.expired? }
        @store[tree].clear
        count
      end

      def fetch(key)
        tree, node = take_key(key)
        cache = @store[tree][node]
        return yield key if cache.nil?

        if cache.expired?
          # expired value
          @store[tree].delete(node)
          return yield key
        end

        cache.data
      end

      def clear
        @store.clear
      end
    end
  end
end
