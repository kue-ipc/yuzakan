# frozen_string_literal: true

module Yuzakan
  module Providers
    class Authenticate < Yuzakan::Operation
      category :user

      # class Validator
      #   include Hanami::Validations
      #   predicates NamePredicates
      #   messages :i18n

      #   validations do
      #     required(:username).filled(:str?, :name?, max_size?: 255)
      #     required(:password).maybe(:str?, max_size?: 255)
      #   end
      # end

      # expose :provider

      # def initialize(provider_repository: ProviderRepository.new)
      #   @provider_repository = provider_repository
      # end

      def call(username, password, providers = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        providers = step get_providers(providers, operation: :user_auth)

        # TODO: 途中で失敗した場合の処理
        providers.find do |provider|
          provider.user_auth(username, password)
        rescue => e
          Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{username}"
          Hanami.logger.error e
          error(I18n.t("errors.action.error", action: I18n.t("interactors.provider_authenticate"),
            target: provider.label))
          error(e.message)
          fail!
        end
      end

      private def authenticate(username, password, providers)
        providers.each do |provider|
          return Success(provider) if provider.user_auth(username, password)
        rescue => e
          Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{username}"
          Hanami.logger.error e
          error(I18n.t("errors.action.error", action: I18n.t("interactors.provider_authenticate"),
            target: provider.label))
          error(e.message)
          fail!
        end

        Failure([:failure, "auth"])
      end

      private def validate_password(password)
        case password
        when ""
          Failure([:empty, "password"])
        when String
          Success(password)
        when nil
          Failure([:nil, "password"])
        else
          Failure([:not_string, "password"])
        end
      end
    end
  end
end
