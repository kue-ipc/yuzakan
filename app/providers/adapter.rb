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
        adapter_class = step get_class(provider)
        step get_params(provider)
        step create(adapter_class, provider)

        provider_params_hash = attributes[:provider_params].to_h do |param|
          [param[:name].intern, param[:value]]
        end
        @params = @adapter_class.normalize_params(provider_params_hash)
        @adapter = @adapter_class.new(@params, group: attributes[:group],
          logger: Hanami.logger)
        Success(adapter)
      end

      def get_provider(provider)
        return Failure(:nil) if provider.nil?

        unless provider.is_a?(Yuzakan::Structs::Provider)
          provider = provider_repo.get(provider.to_s)
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

      def create_adatper(_adapter_class, _params)
        provider_params_hash = attributes[:provider_params].to_h do |param|
          [param[:name].intern, param[:value]]
        end
        @params = @adapter_class.normalize_params(provider_params_hash)
        @adapter = @adapter_class.new(@params, group: attributes[:group],
          logger: Hanami.logger)
        Success(adapter)
      end
    end
  end
end
