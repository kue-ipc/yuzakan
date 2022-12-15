require 'hanami/interactor'
require 'hanami/validations/form'

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
      optional(:clearance_level).filled(:int?)
      optional(:primary_group).filled(:str?, :name?, max_size?: 255)
      optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
      optional(:attrs) { hash? }
      optional(:reserved).maybe(:bool?)
      optional(:note).maybe(:str?, max_size?: 4096)
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
    username = params[:username]
    password = params[:password]

    userdata = {
      username: params[:username],
      display_name: params[:display_name],
      email: params[:email],
      primary_group: params[:primary_group],
      attrs: params[:attrs] || {},
    }

    params[:providers].each do |provider_name|
      provider = @provider_repository.find_with_adapter_by_name(provider_name)
      raise 'プロバイダーが見つかりません。' unless provider

      provider.user_create(username, password, userdata)
    rescue => e
      Hanami.logger.error e
      error!("アカウント作成時にエラーが発生しました。: #{e.message}")
    end

    sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
    result = sync_user.call({username: username})
    error!(result.errors) if result.failure?

    @user = result.user

    error!('ユーザーが作成されていません。') unless @user

    if [:clearance_level, :reserved, :note].any? { |name| params[name] }
      @user = @user_repository.update(@user.id, params.slice(:clearance_level, :reserved, :note))
    end

    @userdata = result.userdata
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
      @provider_repository.ordered_all_with_adapter_by_operation(:user_update)
    end
  end
end
