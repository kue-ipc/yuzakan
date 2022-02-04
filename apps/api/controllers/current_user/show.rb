module Api
  module Controllers
    module CurrentUser
      class Show
        include Api::Action

        def initialize(provider_repository: ProviderRepository.new,
                       attr_repository: AttrRepository.new,
                       **opts)
          super(**opts)
          @provider_repository = provider_repository
          @attr_repository = attr_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          user = current_user
          read_user = ReadUser.new(provider_repository: @provider_repository)
          result = read_user.call(username: user.name)
          userdata = result.userdata || {}
          providers = result.provider_userdatas&.compact&.keys || []
          self.body = JSON.generate({
            **user.to_h,
            data: userdata,
            providers: providers,
          })
        end
      end
    end
  end
end
