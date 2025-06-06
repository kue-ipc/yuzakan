# frozen_string_literal: true

module Yuzakan
  module Providers
    class CreateUser < Yuzakan::ProviderOperation
      category :user

      def call(username, providers = nil, **params)
        username = step validate_name(username)
        providers = step get_providers(providers, method: :user_create)

        password = params.delete(:password)

        # TODO: 途中で失敗した場合の処理
        providers.to_h do |provider|
          adapter = step get_adapter(provider)
          userdata = step map_data(provider, params)
          new_userdata = adapter.user_create(username, userdata, password:)
          result =
            if new_userdata
              new_params = step convert_data(provider, new_userdata)
              cache_delete(provider)
              cache_write(provider, username) { new_params }
              new_params
            end
          [provider.name, result]
        end
      end
    end
  end
end
