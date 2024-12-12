# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"
require_relative "../predicates/name_predicates"

# Userレポジトリと各プロバイダーのユーザー情報同期
module Yuzakan
  module Operations
    class SyncUser < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:str?, :name?, max_size?: 255)
        end
      end

      expose :user
      expose :data
      expose :providers

      def initialize(provider_repository: ProviderRepository.new,
                     user_repository: UserRepository.new,
                     group_repository: GroupRepository.new,
                     member_repository: MemberRepository.new)
        @provider_repository = provider_repository
        @user_repository = user_repository
        @group_repository = group_repository
        @member_repository = member_repository
      end

      def call(params)
        @username = params[:username]

        read_user_result = ProviderReadUser.new(provider_repository: @provider_repository)
          .call({username: @username})
        if read_user_result.failure?
          Hanami.logger.error "[#{self.class.name}] Failed to call ProviderReadUser"
          Hanami.logger.error read_user_result.errors
          error(I18n.t("errors.action.fail", action: I18n.t("interactors.provider_read_user")))
          read_user_result.errors.each { |msg| error(msg) }
          fail!
        end

        @providers = read_user_result.providers.compact

        @data = {attrs: {}, groups: []}
        @providers.each_value do |data|
          %i[username display_name email primary_group].each do |name|
            @data[name] ||= data[name] unless data[name].nil?
          end
          @data[:groups] |= data[:groups] unless data[:groups].nil?
          @data[:attrs] = data[:attrs].merge(@data[:attrs]) unless data[:attrs].nil?
        end

        if @providers.empty?
          unregister_user_result = UnregisterUser.new(user_repository: @user_repository,
                                                      member_repository: @member_repository)
            .call(username: @username)
          if unregister_user_result.failure?
            Hanami.logger.error "[#{self.class.name}] Failed to call UnregisterUser"
            error(I18n.t("errors.action.fail", action: I18n.t("interactors.unregister_user")))
            unregister_user_result.errors.each { |msg| error(msg) }
            fail!
          end
          @user = unregister_user_result.user
        else
          register_user_result = RegisterUser.new(user_repository: @user_repository, group_repository: @group_repository,
                                                  member_repository: @member_repository)
            .call(@data.slice(:username, :display_name, :email, :primary_group, :groups))
          if register_user_result.failure?
            Hanami.logger.error "[#{self.class.name}] Failed to call RegisterUser"
            error(I18n.t("errors.action.fail", action: I18n.t("interactors.register_user")))
            register_user_result.errors.each { |msg| error(msg) }
            fail!
          end
          @user = register_user_result.user
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
