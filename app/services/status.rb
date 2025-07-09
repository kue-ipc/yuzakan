# frozen_string_literal: true

# TODO: 見直し必要

module Yuzakan
  module Providers
    class Authenticate < Yuzakan::ProviderOperation
      category :provider

      def call(provider)
        providers = step get_providers([provider])
        step authenticate(username, password, providers)
      end

      private def authenticate(username, password, providers)
        providers.each do |provider|
          adapter = step get_adapter(provider)
          adapter.status
          return Success(adapter.status)
        rescue => e
          return Failure([:error, e])
        end

        Failure([:failure, t("errors.wrong_username_or_password")])
      end
    end
  end
end
