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
    config_repostiory: ConfigRepository.new,
    network_repository: NetworkRepository.new,
    provider_repository: ProviderRepository.new,
    user_repository: UserRepository.new
  )
    @config_repostiory = config_repostiory
    @network_repostiory = network_repository
    @provider_repostiory = provider_repository
    @user_repository = user_repository
  end

  def call(params)
    config = params[:config]
    admin_user = params[:admin_user]
    setup_local_provider(admin_user[:username], admin_user[:password])
    setup_admin(admin_user[:username])

    @config_repostiory.current_create({
      title: config[:title],
      maintenace: false,
    })
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end
    validation.success?

    if @config_repostiory.initialized?
      error('すでに初期化済みです。')
      return false
    end
    true
  end

  private def setup_local_provider(username, password)
    @provider_repostiory.create({
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
    local_provider = @provider_repostiory.find_with_adapter_by_name('local')
    local_provider.user_create(username, password, display_name: 'ローカル管理者')
  end

  private def setup_admin(username)
    UserRepository.new.create({
      name: username,
      clearance_level: 5,
    })
  end
end
