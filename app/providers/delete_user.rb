# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations/form"

module Yuzakan
  module Providers
    class DeleteUser < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:str?, :name?, max_size?: 255)
        end
      end

      expose :providers
      expose :changed

      def initialize(provider_repository: ProviderRepository.new)
        @provider_repository = provider_repository
      end

      def call(params)
        username = params[:username]

        @changed = false
        @providers = get_providers(params[:providers]).to_h do |provider|
          data = provider.user_delete(username)
          @changed = true if data
          [provider.name, data]
        rescue => e
          logger.error "[#{self.class.name}] Failed on #{provider.name} for #{username}"
          logger.error e
          error(t("errors.action.error", action: t("interactors.provider_delete_user"),
            target: provider.label))
          error(e.message)
          if @changed
            error(t("errors.action.stopped_after_some", action: t("interactors.provider_delete_user"),
              target: t("entities.provider")))
          end
          fail!
        end
      end

      private def valid?(params)
        result = Validator.new(params).validate
        if result.failure?
          logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
          error(result.messages)
          return false
        end

        true
      end

      private def get_providers(provider_names = nil)
        operation = :user_delete
        if provider_names
          provider_names.map do |provider_name|
            provider = @provider_repository.find_with_adapter_by_name(provider_name)
            unless provider
              logger.warn "[#{self.class.name}] Not found: #{provider_name}"
              error!(t("errors.not_found",
                name: t("entities.provider")))
            end

            unless provider.can_do?(operation)
              logger.warn "[#{self.class.name}] No ability: #{provider.name}, #{operation}"
              error!(t("errors.no_ability", name: provider.label,
                action: t(operation, scope: "operations")))
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
