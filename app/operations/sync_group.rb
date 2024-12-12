# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"
require_relative "../predicates/name_predicates"

# Groupレポジトリと各プロバイダーのグループ情報同期
module Yuzakan
  module Operations
    class SyncGroup < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:groupname).filled(:str?, :name?, max_size?: 255)
        end
      end

      expose :group
      expose :data
      expose :providers

      def initialize(provider_repository: ProviderRepository.new,
                     group_repository: GroupRepository.new)
        @provider_repository = provider_repository
        @group_repository = group_repository
      end

      def call(params)
        read_group_result = ProviderReadGroup.new(provider_repository: @provider_repository)
          .call({groupname: params[:groupname]})
        if read_group_result.failure?
          Hanami.logger.error "[#{self.class.name}] Failed to call ProviderReadGroup"
          Hanami.logger.error read_group_result.errors
          error(I18n.t("errors.action.fail", action: I18n.t("interactors.read_group")))
          read_group_result.errors.each { |msg| error(msg) }
          fail!
        end

        @providers = read_group_result.providers.compact

        @data = {primary: false}
        @providers.each_value do |data|
          %i[groupname display_name].each do |name|
            @data[name] ||= data[name] unless data[name].nil?
          end
          @data[:primary] = true if data[:primary]
        end

        if @providers.empty?
          unregister_group_result = UnregisterGroup.new(group_repository: @group_repository)
            .call(groupname: params[:groupname])
          if unregister_group_result.failure?
            Hanami.logger.error "[#{self.class.name}] Failed to call UnregisterGroup"
            error(I18n.t("errors.action.fail", action: I18n.t("interactors.unregister_group")))
            unregister_group_result.errors.each { |msg| error(msg) }
            fail!
          end
          @group = unregister_group_result.group
        else
          register_group_result = RegisterGroup.new(group_repository: @group_repository)
            .call(@data.slice(:groupname, :display_name, :primary))
          if register_group_result.failure?
            Hanami.logger.error "[#{self.class.name}] Failed to call RegisterGroup"
            error(I18n.t("errors.action.fail", action: I18n.t("interactors.register_group")))
            register_group_result.errors.each { |msg| error(msg) }
            fail!
          end
          @group = register_group_result.group
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
    end
  end
end
