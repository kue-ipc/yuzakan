# frozen_string_literal: true

# use Active Support Cache Store

Hanami.app.register_provider(:cache_store) do
  prepare do
    require "active_support"
    require "active_support/cache"
  end

  start do
    store_opts = {
      namespace: "yuzakan:cache",
      expires_in: target["settings"].cache_expire,
    }
    cache_store =
      if target["settings"].cache_expire.zero?
        ActiveSupport::Cache::NullStore.new(**store_opts)
      elsif target["settings"].redis_url
        ActiveSupport::Cache::RedisCacheStore.new(**store_opts,
          url: target["settings"].redis_url)
      elsif target["settings"].cache_path
        ActiveSupport::Cache::FileStore.new(target["settings"].cache_file,
          **store_opts)
      else
        ActiveSupport::Cache::MemoryStore.new(**store_opts)
      end
    register "cache_store", cache_store
  end
end
