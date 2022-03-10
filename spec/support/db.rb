def db_clear
  UserRepository.new.clear
  LocalUserRepository.new.clear
  ProviderRepository.new.clear
  ConfigRepository.new.clear
end

def db_initialize
  InitialSetup.new.call(
    config: {
      title: 'テストシステム',
    },
    admin_user: {
      username: 'admin',
      password: 'pass',
      password_confirmation: 'pass',
    })

  provider_repository = ProviderRepository.new

  # 一般ユーザー
  local_provider = provider_repository.find_with_adapter_by_name('local')
  local_provider.create('user', 'word',
                        display_name: '一般ユーザー',
                        email: 'user@yuzakan.test')
  Authenticate.new(client: '::1', app: 'test').call({username: 'user', password: 'word'})

  # ダミープロバイダー
  UpdateProvider.new(provider_repository: provider_repository).call(
    name: 'dummy', label: 'ダミー', adapter_name: 'dummy')
end

def db_reset
  db_clear
  db_initialize
end
