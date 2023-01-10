# frozen_string_literal: true

module Api
  module Controllers
    module Users
      module UserInteractor
        USER_BASE_INFO = [:username, :display_name, :email].freeze
        USER_PROVIDER_INFO = [:primary_group, :groups, :attrs].freeze
        USER_REPOSITORY_INFO = [:clearance_level, :reserved, :note].freeze

        def initialize(config_repository: ConfigRepository.new,
                       provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)

          super
          @config_repository ||= config_repository
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end

        private def sync_user(params)
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = @sync_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def create_user(params)
          @create_user ||= CreateUser.new(provider_repository: @provider_repository)
          result = @create_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def read_user(params)
          @create_user ||= ReadUser.new(provider_repository: @provider_repository)
          result = @create_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def update_user(params)
          @update_user ||= UpdateUser.new(provider_repository: @provider_repository)
          result = @update_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def delete_user(params)
          @delete_user ||= DeleteUser.new(provider_repository: @provider_repository)
          result = @delete_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def generate_password(params = {})
          @generate_password ||= GeneratePassword.new(config_repository: @config_repository)
          result = @generate_password.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
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
