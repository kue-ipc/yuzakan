# frozen_string_literal: true

module Yuzakan
  module Providers
    class GetAdapter < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "repos.adapter_param_repo",
        "adapters",
      ]

      def call(provider)
        provider = step get_provider(provider)
        adapter_class = step get_class(provider)
        adapter_params = step get_params(provider)

        adapter_class.new(adapter_params,
          group: provider.group, logger: Hanami.logger)
      end

      private def get_provider(provider)
        return Failure(:nil) if provider.nil?

        unless provider.is_a?(Yuzakan::Structs::Provider)
          provider = provider_repo.get(provider.to_s)
        end

        if provider
          Success(provider)
        else
          Failure([:not_found, "provider"])
        end
      end

      private def get_class(provider)
        adapter_class = adapters[provider.adapter]
        if adapter_class
          Success(adapter_class)
        else
          Failure([:not_found, "adapter"])
        end
      end

      private def get_params(provider)
        params =
          if provider.respond_to?(:adapter_params)
            provider.adapter_params
          else
            adapter_param_repo.all_by_provider(provider)
          end
        Success(params)
      end
    end
  end
end
