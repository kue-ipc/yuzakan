# frozen_string_literal: true

module API
  module Actions
    module Users
      module InteractorUser
        USER_BASE_INFO = [:username, :label, :email].freeze
        USER_PROVIDER_INFO = [:primary_group, :groups, :attrs].freeze
        USER_REPOSITORY_INFO = [:clearance_level, :prohibited, :note].freeze

        def initialize(config_repository: ConfigRepository.new,
          provider_repository: ProviderRepository.new,
          user_repository: UserRepository.new,
          group_repository: GroupRepository.new,
          member_repository: MemberRepository.new,
          **opts)
          super
          @config_repository ||= config_repository
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
          @group_repository ||= group_repository
          @member_repository ||= member_repository
        end

        private def call_interacttor(interactor, params)
          result = interactor.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def sync_user(params)
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository,
            user_repository: @user_repository,
            group_repository: @group_repository,
            member_repository: @member_repository)
          call_interacttor(@sync_user, params)
        end

        private def provider_create_user(params)
          @provider_create_user ||= ProviderCreateUser.new(provider_repository: @provider_repository)
          call_interacttor(@provider_create_user, params)
        end

        private def provider_read_user(params)
          @provider_read_user ||= ProviderReadUser.new(provider_repository: @provider_repository)
          call_interacttor(@provider_read_user, params)
        end

        private def provider_update_user(params)
          @provider_update_user ||= ProviderUpdateUser.new(provider_repository: @provider_repository)
          call_interacttor(@provider_update_user, params)
        end

        private def provider_delete_user(params)
          @provider_delete_user ||= ProviderDeleteUser.new(provider_repository: @provider_repository)
          call_interacttor(@provider_delete_user, params)
        end

        private def provider_lock_user(params)
          @provider_lock_user ||= ProviderLockUser.new(provider_repository: @provider_repository)
          call_interacttor(@provider_lock_user, params)
        end

        private def provider_unlock_user(params)
          @provider_unlock_user ||= ProviderUnlockUser.new(provider_repository: @provider_repository)
          call_interacttor(@provider_unlock_user, params)
        end

        private def generate_password(params = {})
          @generate_password ||= GeneratePassword.new(config_repository: @config_repository)
          call_interacttor(@generate_password, params)
        end
      end
    end
  end
end
