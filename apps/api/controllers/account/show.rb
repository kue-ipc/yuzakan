module Api
  module Controllers
    module Account
      class Show
        include Api::Action

        expose :user
        expose :userdata
        expose :providers

        def initialize(provider_repository: ProviderRepository.new,
                       attr_repository: AttrRepository.new,
                       **opts)
          super(**opts)
          @provider_repository = provider_repository
          @attr_repository = attr_repository
        end

        def call(_params)
          @user = current_user
          halt 400 if @user.nil?

          read_user = ReadUser.new(provider_repository: @provider_repository)
          result = read_user.call(username: @user.name)
          @userdata = result.userdata || {}
          @providers = result.provider_userdatas&.compact&.keys || []
        end
      end
    end
  end
end
