# frozen_string_literal: true

module Yuzakan
  module Providers
    class Adapter < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "adapters"
      ]

      def call(provider)
        provider = provider_repo.get(provider) unless provider.is_a?(Yuzakan::Structs::Provider)

        return super if attributes.nil? || attributes[:adapter].nil?

        adapter_class = adapters[provider.adapter]
        raise NoAdapterError, "Not found adapter: #{attributes[:adapter]}" unless @adapter_class

        return super if attributes[:provider_params].nil?

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
        provider =
          if !provider.is_a?(Yuzakan::Structs::Provider)
            provider_repo.get(provider)
          elsif provider.provider_params.nil?
            provider_repo.get(provider) unless provider.is_a?(Yuzakan::Structs::Provider)
          end

        if provider
          Success(provider)
        else
          Failure(:not_found)
        end
      end
    end
  end
end
