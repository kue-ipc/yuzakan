# frozen_string_literal: true

module Yuzakan
  module Providers
    class ChangePassword < Yuzakan::ProviderOperation
      category :user

      def call(username, password, providers = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        providers =
          if providers.nil?
            all_providers = step get_providers(nil, method: :user_change_password)
            all_providers.reject(&:individual_password)
          else
            step get_providers(providers, method: :user_change_password)
          end
        step change_password(username, password, providers)
      end

      private def change_password(username, password, providers)
        changed_providers = providers.select do |provider|
          adapter = step get_adapter(provider)
          adapter.user_change_password(username, password)
        rescue => e
          return Failure([:error, e])
        end

        Sucess(changed_providers)
      end
    end
  end
end
