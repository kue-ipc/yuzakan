module Api
  module Controllers
    module Session
      class Create
        include Api::Action

        security_level 0

        params do
          required(:username).filled(:str?, max_size?: 255)
          required(:password).filled(:str?, max_size?: 255)
        end

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       auth_log_repository: AuthLogRepository.new, **opts)
          super(user_repository: user_repository, **opts)
          @provider_repository = provider_repository
          @auth_log_repository = auth_log_repository
        end

        def call(params)
          halt_json(400, 'パラメーターが不正です。', errors: params.error_messages) unless params.valid?

          redirect_to_json routes.path(:session), '既にログインしています。', status: 303 if current_user

          authenticate = Authenticate.new(user_repository: @user_repository,
                                          provider_repository: @provider_repository,
                                          auth_log_repository: @auth_log_repository,
                                          uuid: uuid, client: client)
          authenticate_result = authenticate.call(username: params[:username], password: params[:password])

          halt_json(422, authenticate_result.errors.first || 'ログインに失敗しました。') if authenticate_result.failure?

          # セッション情報を保存
          session[:user_id] = authenticate_result.user.id
          session[:created_at] = current_time
          session[:updated_at] = current_time

          self.status = 201
          self.body = generate_json({
            username: authenticate_result.user.name,
            display_name: authenticate_result.user.display_name,
            created_at: current_time,
            updated_at: current_time,
          })
        end
      end
    end
  end
end
