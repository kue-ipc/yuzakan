# frozen_string_literal: true

def db_clear
  UserRepository.new.clear
  LocalUserRepository.new.clear
  ProviderRepository.new.clear
  ConfigRepository.new.clear
end

def db_initialize
  InitialSetup.new.call(
    config: {
      title: 'テスト',
    },
    admin_user: {
      username: 'admin',
      password: 'pass',
      password_confirmation: 'pass',
    }
  )
  # 一般ユーザー
  local_provider = ProviderRepository.new.find_by_name_with_params('local')
  adapter = local_provider.adapter
  adapter.create(
    'user',
    display_name: '一般ユーザー',
    email: 'user@yuzakan.test',
  )
  adapter.change_password('user', 'word')
end

def db_reset
  db_clear
  db_initialize
end
