# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"

module Yuzakan
  module Providers
    class ResetPassword < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:str?, :name?, max_size?: 255)
          optional(:providers).each(:str?, :name?, max_size?: 255)
        end
      end

      expose :username
      expose :password
      expose :providers

      def initialize(provider_repository: ProviderRepository.new,
        config_repository: ConfigRepository.new)
        @provider_repository = provider_repository
        @config_repository = config_repository
      end

      def call(params)
        @username = params[:username]
        @password = generate_password

        result = ProviderChangePassword.new(provider_repository: @provider_repository)
          .call({password: @password, **params})
        if result.failure?
          error(t("errors.action.failure",
            action: t("interactors.change_password")))
          result.errors.each { |e| error(e) }
          fail!
        end

        @providers = result.providers
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

      private def generate_password
        result = GeneratePassword.new(config_repository: @config_repository).call({})
        if result.failure?
          error(t("errors.action.failure",
            action: t("interactors.change_password")))
          result.errors.each { |e| error(e) }
          fail!
        end
        result.password
      end
    end
  end
end
