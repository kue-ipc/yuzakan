# frozen_string_literal: true

module Api
  module Controllers
    module Users
      module InteractorUser
        USER_BASE_INFO = [:username, :display_name, :email].freeze
        USER_PROVIDER_INFO = [:primary_group, :groups, :attrs].freeze
        USER_REPOSITORY_INFO = [:clearance_level, :prohibited, :note].freeze

        def initialize(config_repository: ConfigRepository.new,
                       provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       group_repository: GroupRepository.new,
                       **opts)

          super
          @config_repository ||= config_repository
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
          @group_repository ||= group_repository
        end

        private def call_interacttor(interactor, params)
          result = interactor.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def sync_user(params)
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository,
                                      user_repository: @user_repository,
                                      group_repository: @group_repository)
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

        private def generate_password(params = {})
          @generate_password ||= GeneratePassword.new(config_repository: @config_repository)
          call_interacttor(@generate_password, params)
        end

        private def set_sync_user
          result = sync_user({username: @username})
          @user = result.user
          @userdata = result.userdata
          @providers = result.providers
        end

        private def user_json(**data)
          generate_json({
            **convert_for_json(@user, assoc: true),
            userdata: @userdata,
            provider_userdatas: @providers.compact.map { |k, v| {provider: k, userdata: v} },
            **data,
          })
        end
      end
    end
  end
end
