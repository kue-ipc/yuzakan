# frozen_string_literal: true

module Yuzakan
  module Providers
    class Authenticate < Yuzakan::ProviderOperation
      category :user

      def call(username, password, providers = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        providers = step get_providers(providers, method: :user_auth)
        step authenticate(username, password, providers)
      end

      private def authenticate(username, password, providers)
        providers.each do |provider|
          adapter = step get_adapter(provider)
          return Success(provider) if adapter.user_auth(username, password)
        rescue => e
          return Failure([:error, e])
        end

        Failure([:failure, t("errors.wrong_username_or_password")])
      end
    end
  end
end
