# frozen_string_literal: true

module Yuzakan
  module Providers
    class Adapter < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "repos.adapters_params_repo",
        "adapters",
      ]

      def call(provider)
        provider = step get_provider(provider)
        adapter_class = step get_class(provider)
        adapter_params = step get_params(provider)

        adapter_class.new(adapter_params,
          group: provider.group, logger: Hanami.logger)
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

      def get_adapter_params(provider)
        params = provider.adapter_params ||
          adapter_params.all_by_provider(provider)
        Success(params)
      end
    end
  end
end
