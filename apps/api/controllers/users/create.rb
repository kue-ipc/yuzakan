module Api
  module Controllers
    module Users
      class Create
        include Api::Action

        security_level 4

        def initialize(provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end

        def call(params)
          create_user = CreateUser.new(
            user_repository: @user_repository,
            provider_repository: @provider_repository)
          result = create_user.call({username: params[:name], **params.to_h.except(:name)})

          halt_json(422, errors: merge_errors(result.errors)) if result.failure?

          self.status = 201
          headers['Location'] = routes.user_path(result.user.id)
          self.body = generate_json({
            **convert_for_json(result.user),
            password: result.password,
          })
        end
      end
    end
  end
end
