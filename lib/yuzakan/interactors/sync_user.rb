# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

# Userレポジトリと各プロバイダーのユーザー情報同期
class SyncUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
    end
  end

  expose :username
  expose :user
  expose :userdata
  expose :providers

  def initialize(provider_repository: ProviderRepository.new,
                 user_repository: UserRepository.new)
    @provider_repository = provider_repository
    @user_repository = user_repository
  end

  def call(params)
    @username = params[:username]

    read_user_result = ReadUser.new(provider_repository: @provider_repository)
      .call({username: @username})
    if read_user_result.failure?
      Hanami.logger.error "[#{self.class.name}] Failed to call ReadUser"
      Hanami.logger.error read_user_result.errors
      error(I18n.t('errors.action.fail', action: I18n.t('interactors.read_user')))
      read_user_result.errors.each { |msg| error(msg) }
      fail!
    end

    @userdata = read_user_result.userdata
    @providers = read_user_result.providers

    if @providers.values.any?
      if @userdata[:username] != @username
        Hanami.logger.error "[#{self.class.name}] Do not match username: #{@userdata[:username]}"
        error!(I18n.t('errors.eql?', left: I18n.t('attributes.user.username')))
      end

      register_user_result = RegisterUser.new(user_repository: @user_repository)
        .call(@userdata.slice(:username, :display_name, :email, :primary_group, :groups))
      if register_user_result.failure?
        Hanami.logger.error "[#{self.class.name}] Failed to call RegisterUser"
        error(I18n.t('errors.action.fail', action: I18n.t('interactors.register_user')))
        register_user_result.errors.each { |msg| error(msg) }
        fail!
      end
      @user = register_user_result.user
    else
      unregister_user_result = UnregisterUser.new(user_repository: @user_repository)
        .call(username: @username)
      if unregister_user_result.failure?
        Hanami.logger.error "[#{self.class.name}] Failed to call UnregisterUser"
        error(I18n.t('errors.action.fail', action: I18n.t('interactors.unregister_user')))
        unregister_user_result.errors.each { |msg| error(msg) }
        fail!
      end
      @user = unregister_user_result.user
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      Hanami.logger.error "[#{self.class.name}] Validation fails: #{validation.messages}"
      error(validation.messages)
      return false
    end

    true
  end
end
