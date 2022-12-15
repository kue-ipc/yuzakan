require 'hanami/interactor'
require 'hanami/validations/form'

# プロバイダーにユーザーを作成する
class CreateUser
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:password).filled(:str?, max_size?: 255)
      optional(:display_name).filled(:str?, max_size?: 255)
      optional(:email).filled(:str?, :email?, max_size?: 255)
      optional(:primary_group).filled(:str?, :name?, max_size?: 255)
      optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
      optional(:attrs) { hash? }
    end
  end

  expose :user
  expose :providers

  def initialize(provider_repository: ProviderRepository.new,
                 user_repository: UserRepository.new)
    @provider_repository = provider_repository
    @user_repository = user_repository
  end

  def call(params)
    username = params[:username]
    password = params[:password]

    userdata = params.slice(:username, :display_name, :email, :primary_group).merge({
      attrs: params[:attrs] || {},
    })

    get_providers(params[:providers]).each do |provider|
      @providers[provider.name] = provider.user_create(username, password, userdata)
    rescue => e
      Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{username}"
      Hanami.logger.error e
      error(I18n.t('errors.action.error', action: I18n.t('interactors.create_user'), target: provider.label))
      error(e.message)
      fail!
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

  private def get_providers(providers = nil)
    if providers
      providers.map do |provider_name|
        provider = @provider_repository.find_with_adapter_by_name(provider_name)
        unless provider
          Hanami.logger.warn "[#{self.class.name}] Not found: #{provider_name}"
          error!(I18n.t('errors.not_found', name: I18n.t('entities.provider')))
        end

        provider
      end
    else
      @provider_repository.ordered_all_with_adapter_by_operation(:user_create)
    end
  end
end
