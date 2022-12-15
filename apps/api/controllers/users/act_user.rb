module Api
  module Controllers
    module Users
      module ActUser
        def initialize(provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end

        # プロバイダーと同期をとり、ユーザーをセットする。
        private def sync_user!
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = @sync_user.call({username: @username})
          halt_json 500, errors: result.errors if result.failure?

          @user = result.user
          @userdata = result.userdata
          @providers = result.providers
        end

        private def sync_user(params)
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = @sync_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def create_user(params)
          @create_user ||= CreateUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = @create_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def update_user(params)
          @update_user ||= UpdateUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = @update_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def delete_user(params)
          @delete_user ||= DeleteUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = @delete_user.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def user_json(**data)
          sync_user! unless @user
          generate_json({
            **convert_for_json(@user),
            userdata: @userdata,
            provider_userdatas: @providers.compact.map { |k, v| {provider: {name: k}, userdata: v} },
            **data,
          })
        end
      end
    end
  end
end
