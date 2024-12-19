# frozen_string_literal: true

module Yuzakan
  module CacheStore
    SEPARATOR = ":"

    attr_reader :expire, :namespace

    # expire: integer
    # namespace: string with colon separated
    def initialize(expire: 0, namespace: "")
      @expire = expire
      @namespace = namespace
    end

    private def split_key(key)
      key.split(SEPARATOR)
    end

    private def join_keys(*keys)
      keys.join(SEPARATOR)
    end

    private def take_key(key)
      *parents, child = split_key(key)
      [join_keys(*parents), child]
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
