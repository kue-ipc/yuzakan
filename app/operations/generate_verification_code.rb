# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations/form"

module Yuzakan
  module Operations
    class GenerateVerificationCode < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations::Form
        messages_path "config/messages.yml"

        validations do
          optional(:username) { filled? & str? }
        end
      end

      expose :username
      expose :user_datas

      def initialize(
        user:,
        client:,
        providers:,
        config: ConfigRepository.new.current,
        mailer: Mailers::UserNotify
      )
        @user = user
        @client = client
        @config = config
        @providers = providers
        @mailer = mailer
      end

      def call(params)
        @username = params&.[](:username) || @user.name

        activity_params = {
          user_id: @user.id,
          client: @client,
          type: "user",
          target: @username,
          action: "generate_code",
        }

        by_user =
          if @username == @user.name
            :self
          else
            :admin
          end

        mailer_params = {
          user: @user,
          config: @config,
          by_user: by_user,
          action: "バックアップコード生成",
          description: "バックアップコードを生成しました。",
        }

        activity_params[:action] += ":#{@providers.map(&:name).join(',')}"
        mailer_params[:providers] = @providers

        @user_datas = {}
        result = :success

        @providers.each do |provider|
          user_data = provider.user_generate_code(@username)
          @user_datas[provider.name] = user_data if user_data
        rescue => e
          logger.error e
          error("バックアップコード生成時にエラーが発生しました。: #{e.message}")
          result = :error
        end

        if @user_datas.empty?
          error("どのシステムでもバックアップコードは生成されませんでした。")
          result = :failure
        end

        @activity_repository.create(**activity_params, result: result.to_s)
        @mailer&.deliver(**mailer_params, result: result)
      end

      private def valid?(params)
        result = Validator.new(params).validate
        if result.failure?
          logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
          error(result.messages)
          return false
        end

        return true if @user.clearance_level >= 3

        unless @providers&.all?(&:self_management)
          error("自己管理可能なシステム以外でバックアップコードを生成することはできません。")
          return false
        end

        if params&.key?(:username) && params[:username] != @user.name
          error(username: "自分自身以外のバックアップコードを生成することはできません。")
          return false
        end

        true
      end
    end
  end
end
