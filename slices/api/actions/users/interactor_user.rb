# frozen_string_literal: true

module API
  module Actions
    module Users
      module InteractorUser
        USER_BASE_INFO = [:username, :label, :email].freeze
        USER_PROVIDER_INFO = [:primary_group, :groups, :attrs].freeze
        USER_REPOSITORY_INFO = [:clearance_level, :prohibited, :note].freeze

        def initialize(config_repository: ConfigRepository.new,
          service_repository: ServiceRepository.new,
          user_repository: UserRepository.new,
          group_repository: GroupRepository.new,
          member_repository: MemberRepository.new,
          **opts)
          super
          @config_repository ||= config_repository
          @service_repository ||= service_repository
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
          @sync_user ||= SyncUser.new(service_repository: @service_repository,
            user_repository: @user_repository,
            group_repository: @group_repository,
            member_repository: @member_repository)
          call_interacttor(@sync_user, params)
        end

        private def service_create_user(params)
          @service_create_user ||= ServiceCreateUser.new(service_repository: @service_repository)
          call_interacttor(@service_create_user, params)
        end

        private def service_read_user(params)
          @service_read_user ||= ServiceReadUser.new(service_repository: @service_repository)
          call_interacttor(@service_read_user, params)
        end

        private def service_update_user(params)
          @service_update_user ||= ServiceUpdateUser.new(service_repository: @service_repository)
          call_interacttor(@service_update_user, params)
        end

        private def service_delete_user(params)
          @service_delete_user ||= ServiceDeleteUser.new(service_repository: @service_repository)
          call_interacttor(@service_delete_user, params)
        end

        private def service_lock_user(params)
          @service_lock_user ||= ServiceLockUser.new(service_repository: @service_repository)
          call_interacttor(@service_lock_user, params)
        end

        private def service_unlock_user(params)
          @service_unlock_user ||= ServiceUnlockUser.new(service_repository: @service_repository)
          call_interacttor(@service_unlock_user, params)
        end

        private def generate_password(params = {})
          @generate_password ||= GeneratePassword.new(config_repository: @config_repository)
          call_interacttor(@generate_password, params)
        end
      end
    end
  end
end
