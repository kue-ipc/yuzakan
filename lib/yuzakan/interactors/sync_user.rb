require 'hanami/interactor'
require 'hanami/validations'
require_relative '../predicates/name_predicates'

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

  expose :user
  expose :userdata
  expose :providers

  def initialize(provider_repository: ProviderRepository.new,
                 user_repository: UserRepository.new)
    @provider_repository = provider_repository
    @user_repository = user_repository
  end

  def call(params)
    read_user = ReadUser.new(provider_repository: @provider_repository)
    result = read_user.call({username: params[:username]})
    if result.failure?
      Hanami.logger.error "[#{self.class.name}] Failed to call ReadUser"
      error(I18n.t('errors.action.fail', action: I18n.t('interactors.read_user')))
      result.errors.each { |msg| error(msg) }
      fail!
    end

    @userdata = result.userdata
    @providers = result.providers

    if @userdata[:username] != params[:username]
      Hanami.logger.error "[#{self.class.name}] Usernames not equal: #{@userdata[:username]}, #{params[:username]}"
      error!(I18n.t('errors.eql?', left: I18n.t('attributes.user.username'))) 
    end

    if @providers.values.any?
      register_user_result = RegisterUser.new(user_repository: @user_repository).call(
        @userdata.slice(:username, :display_name, :email, :primary_group, :groups))
      if register_user_result.failure?
        Hanami.logger.error "[#{self.class.name}] Failed to call RegisterUser"
        error(I18n.t('errors.action.fail', action: I18n.t('interactors.register_user')))
        register_user_result.errors.each { |msg| error(msg) }
        fail!
      end
      @user = register_user_result.user
    else
      unregister_user_result = UnregisterUser.new(user_repository: @user_repository).call(
        @userdata.slice(:username))
      if unregister_user_result.failure?
        Hanami.logger.error "[#{self.class.name}] Failed to call UnregisterUser"
        error(I18n.t('errors.action.fail', action: I18n.t('interactors.unregister_user')))
        unregister_user_result.errors.each { |msg| error(msg) }
        fail!
      end
      @user = nil
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
