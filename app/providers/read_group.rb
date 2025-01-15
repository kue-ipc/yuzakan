# frozen_string_literal: true

module Yuzakan
  module Providers
    class ReadGroup < Yuzakan::ProviderOperation
      category :group

      def call(groupname, providers = nil)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers, operation: :group_read)

        providers.to_h do |provider|
          data =
            if provider.can_do?(:group_read)
              cache_fetch(provider, groupname) do
                adapter = step get_adapter(provider)
                groupdata = adapter.group_read(groupname)
                step convert_data(provider, groupdata)
              end
            end
          [provider.name, data]
        end
      end
    end
  end
end
