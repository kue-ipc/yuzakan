module Api
  module Controllers
    module Users
      class Create
        include Api::Action

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:username).filled(:str?, :name?, max_size?: 255)
            optional(:password).filled(:str?, max_size?: 255)
            optional(:display_name).filled(:str?, max_size?: 255)
            optional(:email).filled(:str?, :email?, max_size?: 255)
            optional(:clearance_level).filled(:int?)
            optional(:primary_group).filled(:str?, :name?, max_size?: 255)
            optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
            optional(:attrs) { hash? }
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       config_repository: ConfigRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
          @config_repository ||= config_repository
        end

        def call(params)
          param_errors = only_first_errors(params.errors)

          unless param_errors.key?(:username)
            sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
            result = sync_user.call({username: params[:username]})
            halt_json 500, erros: result.errors if result.failure?

            param_errors[:username] = [I18n.t('errors.uniq?')] if result.user
          end

          halt_json(422, errors: [param_errors]) unless param_errors.empty?

          password = params[:password] || generate_password

          create_user = CreateUser.new(user_repository: @user_repository,
                                       provider_repository: @provider_repository)
          result = create_user.call({**params.to_h, password: password})
          halt_json 500, erros: result.errors if result.failure?

          self.status = 201
          headers['Location'] = routes.user_path(result.user.username)
          self.body = generate_json({
            **convert_for_json(result.user),
            password: password,
            userdata: result.userdata,
            provider_userdatas: result.providers.compact.map { |k, v| {provider: {name: k}, userdata: v} },
          })
        end

        private def generate_password
          result = GeneratePassword.new(config_repository: @config_repository).call({})
          halt_json 500, erros: result.errors if result.failure?
          result.password
        end
      end
    end
  end
end
