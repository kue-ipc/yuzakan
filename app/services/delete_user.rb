# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations/form"

module Yuzakan
  module Services
    class DeleteUser < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations

        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:name, max_size?: 255)
        end
      end

      expose :services
      expose :changed

      def initialize(service_repository: ServiceRepository.new)
        @service_repository = service_repository
      end

      def call(params)
        username = params[:username]

        @changed = false
        @services = get_services(params[:services]).to_h do |service|
          data = service.user_delete(username)
          @changed = true if data
          [service.name, data]
        rescue => e
          logger.error "[#{self.class.name}] Failed on #{service.name} for #{username}"
          logger.error e
          error(t("errors.action.error", action: t("interactors.service_delete_user"),
            target: service.label))
          error(e.message)
          if @changed
            error(t("errors.action.stopped_after_some", action: t("interactors.service_delete_user"),
              target: t("entities.service")))
          end
          fail!
        end
      end

      def user_delete(username)
        need_adapter!
        need_mappings!

        raw_userdata = @adapter.user_delete(username)
        return if raw_userdata.nil?

        @cache_store[user_key(username)] = nil
        clear_user_list_cache
        convert_userdata(raw_userdata)
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

      private def get_services(service_names = nil)
        operation = :user_delete
        if service_names
          service_names.map do |service_name|
            service = @service_repository.find_with_adapter_by_name(service_name)
            unless service
              logger.warn "[#{self.class.name}] Not found: #{service_name}"
              error!(t("errors.not_found",
                name: t("entities.service")))
            end

            unless service.can_do?(operation)
              logger.warn "[#{self.class.name}] No ability: #{service.name}, #{operation}"
              error!(t("errors.no_ability", name: service.label,
                action: t(operation, scope: "operations")))
            end

            service
          end
        else
          @service_repository.ordered_all_with_adapter_by_operation(operation)
        end
      end
    end
  end
end
