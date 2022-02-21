module Api
  module Controllers
    module CurrentUser
      class Show
        include Api::Action

        def initialize(provider_repository: ProviderRepository.new,
                       **opts)
          super(**opts)
          @provider_repository = provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          user = current_user
          read_user = ReadUser.new(provider_repository: @provider_repository)
          result = read_user.call(username: user.name)
          userdata = result.userdata || {}
          providers = result.provider_userdatas&.compact&.keys || []
          self.body = generate_json({
            name: user.name,
            display_name: user.display_name,
            email: user.email,
            clearance_level: user.clearance_level,
            created_at: user.created_at,
            updated_at: user.updated_at,
            userdata: userdata,
            providers: providers,
          })
        end
      end
    end
  end
end
