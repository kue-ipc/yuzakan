# frozen_string_literal: true

module Yuzakan
  module CacheStore
    attr_reader :expires_in

    def initialize(expires_in: 0)
      @expires_in = expires_in
    end

    def fetch_or_store(key, &)
      fetch(key) do
        self[key] = yield key
      end
    end
  end
end
