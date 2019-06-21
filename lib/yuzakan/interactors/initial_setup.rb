# frozen_string_literal: true

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
    setup_role_and_admin(admin_user[:username])

    @config_repostiory.create(
      title: config[:title],
      maintenace: false,
    )
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(params: validation.messages)
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
    ProviderRepository.new.create(
      name: 'local',
      display_name: 'ローカル',
      immutable: true,
      order: '0',
      adapter_name: 'LocalAdapter',
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      lockable: true,
    )
    local_provider = ProviderRepository.new.by_name_with_params('local')
    local_provider_adapter = local_provider.one.adapter
    local_provider_adapter.create(
      username,
      display_name: 'ローカル管理者',
    )
    local_provider_adapter.change_password(username, password)
  end

  private def setup_role_and_admin(username)
    role_repo = RoleRepository.new
    role_repo.create(
      name: 'default',
      display_name: 'デフォルト',
      immutable: true,
      admin: false,
    )

    admin_role = role_repo.create(
      name: 'admin',
      display_name: '管理者',
      immutable: true,
      admin: true,
    )

    UserRepository.new.create(
      name: username,
      role_id: admin_role.id,
    )
  end
end
