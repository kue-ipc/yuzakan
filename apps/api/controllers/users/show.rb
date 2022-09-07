require_relative './set_user'

module Api
  module Controllers
    module Users
      class Show
        include Api::Action
        include SetUser

        security_level 2

        def initialize(provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = user_json
        end
      end
    end
  end
end
