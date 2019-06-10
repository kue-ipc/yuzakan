# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class InitialSetup
  include Hanami::Interactor

  class Validations
    include Hanami::Validations

    validations do
      required(:username) { filled? }
      required(:password).filled.confirmation
    end
  end

  def call(username:, password:, password_confirmation:)
    setup_local_provider(username, password)
    setup_role_and_admin(username)

    ConfigRepository.new.create(
      initialized: true,
    )
  end

  private def setup_local_provider(username, password)
    local_provider = ProviderRepository.new.create(
      name: 'ローカル',
      immutable: true,
      order: '0',
      adapter_name: 'LocalAdapter',
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      lockable: true
    )

    local_provider_adapter = local_provider.adapter.new({})
    local_provider_adapter.create(
      username,
      display_name: 'ローカル管理者'
    )
    local_provider_adapter.change_password(username, password)
  end

  private def setup_role_and_admin(username)
    role_repo = RoleRepository.new
    none_role = role_repo.create(
      name: '権限なし',
      immutable: true,
      admin: false
    )

    admin_role = role_repo.create(
      name: '管理者',
      immutable: true,
      admin: true
    )

    UserRepository.new.create(
      name: username,
      role_id: admin_role.id
    )
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    error(validation.messages) if validation.failure?

    validation.success?
  end
end
