# frozen_string_literal: true

module Yuzakan
  module Providers
    class Authenticate < Yuzakan::ProviderOperation
      category :user

      def call(username, password, providers = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        providers = step get_providers(providers, operation: :user_auth)
        step authenticate(username, password, providers)
      end

      private def authenticate(username, password, providers)
        providers.each do |provider|
          return Success(provider) if provider.user_auth(username, password)
        rescue => e
          return Failure([:error, e])
        end

        Failure([:failure, :wrong_username_or_password])
      end

      private def validate_password(password)
        case password
        when "", nil
          Failure([:invalid, {password: [:filled?]}])
        when String
          Success(password)
        else
          Failure([:invalid, {password: [:str?]}])
        end
      end
    end
  end
end
