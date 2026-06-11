# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"

module Yuzakan
  module Services
    class ResetPassword < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations

        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:name, max_size?: 255)
          optional(:services).each(:name, max_size?: 255)
        end
      end

      expose :username
      expose :password
      expose :services

      def initialize(service_repository: ServiceRepository.new,
        config_repository: ConfigRepository.new)
        @service_repository = service_repository
        @config_repository = config_repository
      end

      def call(params)
        @username = params[:username]
        @password = generate_password

        result = ServiceChangePassword.new(service_repository: @service_repository)
          .call({password: @password, **params})
        if result.failure?
          error(t("errors.action.failure",
            action: t("interactors.change_password")))
          result.errors.each { |e| error(e) }
          fail!
        end

        @services = result.services
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
