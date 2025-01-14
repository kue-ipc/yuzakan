# frozen_string_literal: true

module Yuzakan
  module Providers
    class CreateGroup < Yuzakan::ProviderOperation
      include Deps[
        "providers.get_adapter",
        "providers.convert_data",
        "providers.map_data",
        "cache_store",
      ]

      category :group

      def call(groupname, providers = nil, **)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers, operation: :group_create)

        providers.to_h do |provider|
          data = step create_group(provider, groupname, **)
          [provider.name, data]
        end
      end

      private def create_group(provider, groupname, **params)
        return Success(nil) unless provider.can_do?(:group_create)

        provider_adapter = step get_adapter.call(provider)
        groupdata = step map_data.call(provider, params, category:)

        result = provider_adapter.group_create(groupname, groupdata)

        if result
          data = step convert_data.call(provider, result, category:)

          chace_store.delete(cache_key(provider))
          cache_store.write(cache_key(provider, groupname), data)
          Success(data)
        else
          Failuer([:exist, "group"])
        end
      end
    end
  end
end
