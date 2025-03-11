# frozen_string_literal: true

module Yuzakan
  module Providers
    class CreateGroup < Yuzakan::ProviderOperation
      category :group

      def call(groupname, providers = nil, **params)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers, operation: :group_create)

        # TODO: 途中で失敗した場合の処理
        providers.to_h do |provider|
          adapter = step get_adapter(provider)
          groupdata = step map_data(provider, params)
          new_groupdata = adapter.group_create(groupname, groupdata)
          result =
            if new_groupdata
              new_params = step convert_data(provider, new_groupdata)
              cache_delete(provider)
              cache_write(provider, groupname) { new_params }
              new_params
            end
          [provider.name, result]
        end
      end
    end
  end
end
