# frozen_string_literal: true

Hanami.app.register_provider(:cache_store) do
  start do
    cache_store =
      if target["settings"].cache_expire.zero?
        Yuzakan::CacheStore::Null.new
      elsif target["settings"].redis_url
        Yuzakan::CacheStore::Redis.new(
          expires_in: target["settings"].cache_expire,
          namespace: "yuzakan:chache", redis_url: target["settings"].redis_url)
      else
        Yuzakan::CacheStore::Memory.new(expires_in: target["settings"].cache_expire)
      end
    register "cache_store", cache_store
  end
end
