require 'hanami/interactor'
require 'hanami/validations'

class InitialSetup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:config).schema do
        required(:title) { filled? }
      end
      required(:admin_user).schema do
        required(:username) { filled? }
        required(:password).filled.confirmation
      end
    end
  end

  def initialize
    @config_repostiory = ConfigRepository.new
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
    ProviderRepository.new.create({
      name: 'local',
      display_name: 'ローカル',
      immutable: true,
      order: '0',
      adapter_name: 'local',
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      lockable: true,
    })
    local_provider = ProviderRepository.new.find_by_name_with_adapter('local')
    local_provider_adapter = local_provider.adapter
    local_provider_adapter.create(username, {display_name: 'ローカル管理者'})
    local_provider_adapter.change_password(username, password)
  end

  private def setup_admin(username)
    UserRepository.new.create({
      name: username,
      admin: true,
    })
  end
end
