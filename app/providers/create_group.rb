# frozen_string_literal: true

module Yuzakan
  module Providers
    class CreateGroup < Yuzakan::ProviderOperation
      category :group

      def call(groupname, providers = nil, **params)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers, operation: :group_create)

        providers.to_h do |provider|
          data = nil
          if provider.can_do?(:group_create)
            adapter = step get_adapter(provider)
            groupdata = step map_data(provider, params, category:)

            if (result = adapter.group_create(groupname, groupdata))
              data = step convert_data(provider, result, category:)
              cache_delete(provider)
              cache_write(provider, groupname) { data }
            end
          end
          [provider.name, data]
        end
      end
    end
  end
end
