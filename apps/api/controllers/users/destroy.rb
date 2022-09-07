require_relative './set_user'

module Api
  module Controllers
    module Users
      class Destroy
        include Api::Action
        include SetUser

        security_level 4

        def initialize(provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end

        def call(params)
          delete_user = DeleteUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = delete_user.call({username: @user.username})
          halt_json 500, erros: result.errors if result.failure?

          self.body = user_json
        end
      end
    end
  end
end
