# frozen_string_literal: true

module Yuzakan
  module Providers
    class ReadUser < Yuzakan::ProviderOperation
      category :user

      def call(username, providers = nil)
        username = step validate_name(username)
        providers = step get_providers(providers, operation: :user_read)

        # TODO: 途中で失敗した場合の処理
        providers.to_h { |provider|
          result =
            cache_fetch(provider, username) {
              adapter = step get_adapter(provider)
              userdata = adapter.user_read(username)
              step convert_data(provider, userdata)
            }
          [provider.name, result]
        }.compact
      end
    end
  end
end
