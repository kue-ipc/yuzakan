# frozen_string_literal: true

module Yuzakan
  module Providers
    class ReadGroup < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "providers.get_adapter",
        "providers.convert_data",
        "cache_store",
      ]

      def call(groupname, providers = nil)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers)

        providers.to_h do |provider|
          data = step read_group(provider, groupname)
          [provider.name, data]
        end
      end

      private def get_providers(providers = nil)
        providers =
          case providers
          in nil
            provider_repo.ordered_all_with_adapter_by_operation(:group_read)
          in []
            []
          in [String | Symbol, *]
            providers.map { |provider| provider_repo.get(provider) }.compact
          in [Yuzakann::Struct::Provider, *]
            providers
          else
            Failure(:invalid_provider_list)
          end
        Success(providers)
      end

      private def read_group(provider, groupname)
        return nil unless provider.group

        name = "provider:#{provider.name}:group:#{groupname}"
        data = cache_store.fetch(name) do
          provider_adapter = step get_adapter.call(provider)
          groupdata = provider_adapter.group_read(groupname)
          step convert_data.call(provider, groupdata, category: :group)
        end
        Success(data)
      end
    end
  end
end
