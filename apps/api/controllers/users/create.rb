require_relative './sync_user'

module Api
  module Controllers
    module Users
      class Create
        include Api::Action
        include SyncUser

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:username).filled(:str?, :name?, max_size?: 255)
            # プロバイダー
            optional(:password).filled(:str?, max_size?: 255)
            optional(:display_name).filled(:str?, max_size?: 255)
            optional(:email).filled(:str?, :email?, max_size?: 255)
            optional(:primary_group).filled(:str?, :name?, max_size?: 255)
            optional(:providers) { array? { each { str? & name? & max_size?(255) } } }
            optional(:attrs) { hash? }
            # レポジトリ
            optional(:clearance_level).filled(:int?)
            optional(:reserved).maybe(:bool?)
            optional(:note).maybe(:str?, max_size?: 4096)
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
          halt_json 400, errors: [params.errors] unless params.valid?

          @username = params[:username]
          sync_user!
          halt_json 422, {username: [I18n.t('errors.uniq?')]} if @user

          password = params[:password] || generate_password

          create_user = CreateUser.new(user_repository: @user_repository,
                                       provider_repository: @provider_repository)
          result = create_user.call({**params.to_h, password: password})
          halt_json 500, errors: result.errors if result.failure?

          sync_user!
          if @user.nil?
            @user = @user_repository.create(
              params.slice(:username, :display_name, :email, :clearance_level, :reserved, :note))
          elsif [:clearance_level, :reserved, :note].any? { |name| params[name] }
            @user = @user_repository.update(@user.id, params.slice(:clearance_level, :reserved, :note))
          end

          self.status = 201
          headers['Location'] = routes.user_path(result.user.username)
          self.body = user_json(password: password)
        end

        private def generate_password
          result = GeneratePassword.new(config_repository: @config_repository).call({})
          halt_json 500, errors: result.errors if result.failure?
          result.password
        end

        private def create_user!
        end
      end
    end
  end
end
