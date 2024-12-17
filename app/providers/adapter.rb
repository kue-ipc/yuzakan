# frozen_string_literal: true

module Yuzakan
  module Providers
    class Adapter < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "adapters"
      ]

      def call(provider)
        provider = step get_provider(provider)
        adapter_class = step get_adapter_class(provider.adapter)

        # cache_store
        expires_in = case Hanami.env
                     when "production" then 60 * 60
                     when "development" then 60
                     else 0
                     end
        namespace = ["yuzakan", "provider", attributes[:name]].join(":")
        redis_url = ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")
        @cache_store = Yuzakan::Utils::CacheStore.create_store(
          expires_in: expires_in, namespace: namespace, redis_url: redis_url)

        provider_params_hash = attributes[:provider_params].to_h do |param|
          [param[:name].intern, param[:value]]
        end
        @params = @adapter_class.normalize_params(provider_params_hash)
        @adapter = @adapter_class.new(@params, group: attributes[:group], logger: Hanami.logger)
        super
      end

      def get_provider(provider)
        return Failure(:nil) if provider.nil?

        provider =
          if provider.is_a?(Yuzakan::Structs::Provider)
            provider_repo.get(provider.to_s)
          elsif provider.provider_params.nil?
            provider_repo.get(provider.name)
          else
            provider
          end

        if provider
          Success(provider)
        else
          Failure(:not_found)
        end
      end

      def get_adapter_class(name)
        adapter_class = adapters[name]
        if adapter_class
          Success(adapter_class)
        else
          Failure(:not_found)
        end
      end
    end
  end
end
