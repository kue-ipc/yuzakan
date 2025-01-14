# frozen_string_literal: true

module Yuzakan
  module Providers
    class ReadGroup < Yuzakan::ProviderOperation
      include Deps[
        "providers.get_adapter",
        "providers.convert_data",
        "cache_store",
      ]

      def call(groupname, providers = nil)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers, operation: :group_read)

        providers.to_h do |provider|
          data = step read_group(provider, groupname)
          [provider.name, data]
        end
      end

      private def read_group(provider, groupname)
        return Success(nil) unless provider.can_do?(:group_read)

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
