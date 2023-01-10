# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class ResetPassword
  include Hanami::Interactor

  class Validations
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

    change_password = ChangePassword.new(provider_repository: @provider_repository)
    result = change_password.call({password: @password, **params})
    if result.failure?
      error(I18n.t('errors.action.fail', action: I18n.t('interactors.change_password')))
      result.errors.each { |e| error(e) }
      fail!
    end

    @providers = result.providers
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

  private def generate_password
    result = GeneratePassword.new(config_repository: @config_repository).call({})
    if result.failure?
      error(I18n.t('errors.action.fail', action: I18n.t('interactors.change_password')))
      result.errors.each { |e| error(e) }
      fail!
    end
    result.password
  end
end
