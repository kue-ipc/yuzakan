# frozen_string_literal: true

module Yuzakan
  module Providers
    class ReadGroup < Yuzakan::ProviderOperation
      category :group

      def call(groupname, providers = nil)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers, method: :group_read)

        # TODO: 途中で失敗した場合の処理
        providers.to_h do |provider|
          result =
            cache_fetch(provider, groupname) do
              adapter = step get_adapter(provider)
              groupdata = adapter.group_read(groupname)
              step convert_data(provider, groupdata)
            end
          [provider.name, result]
        end.compact
      end
    end
  end
end
