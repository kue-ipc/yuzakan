# frozen_string_literal: true

module Yuzakan
  module Providers
    class GetAdapter < Yuzakan::ProviderOperation
      include Deps[
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

      private def get_class(provider)
        if (adapter_class = adapters[provider.adapter])
          Success(adapter_class)
        else
          Failure([:not_found, "adapter"])
        end
      end

      private def get_params(provider)
        if provider.respond_to?(:adapter_params)
          Success(provider.adapter_params)
        else
          Success(adapter_param_repo.all_by_provider(provider))
        end
      end
    end
  end
end
