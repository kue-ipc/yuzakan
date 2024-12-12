# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"

module Yuzakan
  module Providers
    class Authenticate < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:str?, :name?, max_size?: 255)
          required(:password).maybe(:str?, max_size?: 255)
        end
      end

      expose :provider

      def initialize(provider_repository: ProviderRepository.new)
        @provider_repository = provider_repository
      end

      def call(params)
        username = params[:username]

        @provider = get_providers.find do |provider|
          provider.user_auth(params[:username], params[:password])
        rescue => e
          Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{username}"
          Hanami.logger.error e
          error(I18n.t("errors.action.error", action: I18n.t("interactors.provider_authenticate"),
                                              target: provider.label))
          error(e.message)
          fail!
        end
      end

      private def valid?(params)
        result = Validator.new(params).validate
        if result.failure?
          Hanami.logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
          error(result.messages)
          return false
        end

        true
      end

      private def get_providers(providers = nil)
        @provider_repository.ordered_all_with_adapter_by_operation(:user_auth)

        operation = :user_auth
        if providers
          providers.map do |provider_name|
            provider = @provider_repository.find_with_adapter_by_name(provider_name)
            unless provider
              Hanami.logger.warn "[#{self.class.name}] Not found: #{provider_name}"
              error!(I18n.t("errors.not_found", name: I18n.t("entities.provider")))
            end

            unless provider.can_do?(operation)
              Hanami.logger.warn "[#{self.class.name}] No ability: #{provider.name}, #{operation}"
              error!(I18n.t("errors.no_ability", name: provider.label, action: I18n.t(operation, scope: "operations")))
            end

            provider
          end
        else
          @provider_repository.ordered_all_with_adapter_by_operation(operation)
        end
      end
    end
  end
end
