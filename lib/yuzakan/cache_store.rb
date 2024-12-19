# frozen_string_literal: true

module Yuzakan
  module CacheStore
    attr_reader :expire, :namespace

    # expire: integer
    # namespace: array or string
    def initialize(expire: 0, namespace: nil)
      @expire = expire
      @namespace = normalize_key(namespace)
    end

    private def normalize_key(key)
      Array(key)
    end

    # need to define methods
    # * key?(key) => boolean
    # * [](key) => object or nil
    # * []=(key, value) => value
    # * delete(key) => value
    # * delete_all(key) => integer
    # * clear => self
    alias store []=

    def fetch(key)
      value = self[key]
      return value if key?(key)

      yield key
    end

    def fetch_or_store(key)
      fetch(key) do
        self[key] = yield key
      end
    end
  end
end
