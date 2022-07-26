require 'hanami/interactor'
require 'hanami/validations'

class InitialSetup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:config).schema do
        required(:title) { filled? }
      end
      required(:admin_user).schema do
        required(:username).filled(:str?, :name?, max_size?: 255)
        required(:password).filled.confirmation
      end
    end
  end

  def initialize(
    config_repository: ConfigRepository.new,
    network_repository: NetworkRepository.new,
    provider_repository: ProviderRepository.new,
    user_repository: UserRepository.new
  )
    @config_repository = config_repository
    @network_repository = network_repository
    @provider_repository = provider_repository
    @user_repository = user_repository
  end

  def call(params)
    config = params[:config]
    admin_user = params[:admin_user]

    setup_config(config)
    setup_local_provider
    setup_admin(admin_user)
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end
    validation.success?

    if @config_repository.initialized?
      error(I18n.t('errors.already_initialized'))
      return false
    end

    true
  end

  private def setup_config(config)
    @config_repository.current_create({
      **config,
      maintenace: false,
    })
  end

  private def setup_local_provider
    @provider_repository.create({
      name: 'local',
      label: 'ローカル',
      order: '0',
      adapter_name: 'local',
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      lockable: true,
    })
  end

  private def setup_admin(admin_user)
    create_user = CreateUser.new(
      provider_repository: @provider_repository,
      user_repository: @user_repository,
      config_repository: @config_repository)
    result = create_user.call({
      **admin_user,
      providers: ['local'],
      display_name: 'ローカル管理者',
      clearance_level: 5,
    })
    if result.failure?
      result.errors.each { |e| error e }
      error!('管理者の作成に失敗しました。')
    end
  end
end
