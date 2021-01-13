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
  local_provider = provider_repository.find_by_name_with_params('local')
  adapter = local_provider.adapter
  adapter.create(
    'user',
    display_name: '一般ユーザー',
    email: 'user@yuzakan.test')
  adapter.change_password('user', 'word')
  Authenticate.new(client: '::1').call({username: 'user', password: 'word'})

  # ダミープロバイダー
  UpdateProvider.new(provider_repository: provider_repository).call(
    name: 'dummy',
    display_name: 'ダミー',
    adapter_name: 'dummy')
end

def db_reset
  db_clear
  db_initialize
end
