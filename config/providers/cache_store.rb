# frozen_string_literal: true

Hanami.app.register_provider(:cache_store) do
  start do
    cache_opts = {
      expire: target["settings"].cache_expire,
      namespace: "yuzakan:cache",
    }
    cache_store =
      if target["settings"].cache_expire.zero?
        Yuzakan::CacheStore::NullStore.new(**cache_opts)
      elsif target["settings"].redis_url
        Yuzakan::CacheStore::RedisStore.new(**cache_opts,
          redis_url: target["settings"].redis_url)
      else
        Yuzakan::CacheStore::MemoryStore.new(**cache_opts)
      end
    register "cache_store", cache_store
  end
end
