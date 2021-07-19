module Yuzakan
  module Utils
    class CacheStore
      def self.create_store(expires_in: 0, **opts)
        if expires_in > 0
          RedisCacheStore.new(expires_in: expires_in, **opts)
        else
          NoCacheStore.new
        end
      end

      class RedisCacheStore
        def initialize(expires_in: 0,
                       namespace: 'yuzakan:cache',
                       redis_url: 'redis://127.0.0.1:6379/0')
          @cache = Readthis::Cache.new(
            expires_in: expires_in,
            namespace: namespace,
            redis: {url: redis_url})
        end

        def [](key)
          @cache.read(key)
        end

        def []=(key, value)
          @cache.write(key, value)
        end

        def delete(key)
          @cache.delet(key)
        end

        def fetch(key, default = nil, &block)
          @cache.fetch(key, default, &block)
        end

        def clear
          @cache.clear
        end
      end

      class NoCacheStore
        def [](_key)
          nil
        end

        def []=(_key, value)
          value
        end

        def delete(key)
          nil
        end

        def fetch(key, default = nil)
          if block_given?
            yield key
          else
            default
          end
        end

        def clear
          self
        end
      end
    end
  end
end
