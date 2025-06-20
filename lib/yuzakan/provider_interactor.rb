# frozen_string_literal: true

require "hanami/interactor"
require "hanami/utils/string"

module Yuzakan
  module ProviderInteractor
    def self.included(interactor)
      if interactor.is_a?(Class)
        interactor.class_eval do
          include Hanami::Interactor
          expose :providers
          expose :changed
        end
      else
        interactor.define_singleton_method(:included, &method(:included))
      end
    end

    def initialize(provider_repository: ProviderRepository.new, **_opts)
      @provider_repository = provider_repository
    end

    private def call_providers(provider_names = nil, operation: :check)
      @changed = false
      @providers = get_providers(provider_names, method: operation).to_h do |provider|
        data = yield provider
        @changed = true if data
        [provider.name, data]
      rescue => e
        logger.error "[#{self.class.name}] Failed on #{provider.name}"
        logger.error e
        error(t("errors.action.error",
          action: t(
            Hanami::Utils::String.underscore(self.class.name), scope: "interactors"),
          target: provider.label))
        error(e.message)
        if @changed
          error(t("errors.action.stopped_after_some",
            action: t(
              Hanami::Utils::String.underscore(self.class.name), scope: "interactors"),
            target: t("entities.provider")))
        end
        fail!
      end
    end

    private def valid?(params)
      return true unless defined? Validator

      result = Validator.new(params).validate
      if result.failure?
        logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
        error(result.messages)
        return false
      end

      true
    end

    private def get_providers(provider_names = nil, operation: :check)
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
        @provider_repository.ordered_all_with_adapter_by_operation(operation).reject(&:individual_password)
      end
    end
  end
end
