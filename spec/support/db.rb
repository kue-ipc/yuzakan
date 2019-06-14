# frozen_string_literal: true

def db_clear
  UserRepository.new.clear
  RoleRepository.new.clear
  LocalUserRepository.new.clear
  ProviderRepository.new.clear
  ConfigRepository.new.clear
end

def db_initialize
  unless ConfigRepository.new.initialized?
    InitialSetup.new.call(
      admin_user: {
        username: 'admin',
        password: 'pass',
        password_confirmation: 'pass',
      }
    )
  end
end

def db_reset
  db_clear
  db_initialize
end
