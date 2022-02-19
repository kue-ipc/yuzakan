module Api
  module Controllers
    module Session
      class Create
        include Api::Action

        security_level 0

        params do
          required(:session).schema do
            required(:username).filled(:str?, max_size?: 255)
            required(:password).filled(:str?, max_size?: 255)
          end
        end

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       auth_log_repository: AuthLogRepository.new, **opts)
          super(user_repository: user_repository, **opts)
          @provider_repository = provider_repository
          @auth_log_repository = auth_log_repository
        end

        def call(params)
          if current_user
            halt 409, JSON.generate({
              code: 409,
              message: '既にログインしています。',
            })
          end

          unless params.valid?
            halt 400, JSON.generate({
              code: 400,
              message: 'パラメーターが不正です。',
              errors: params.error_messages,
            })
          end

          authenticate = Authenticate.new(user_repository: @user_repository,
                                          provider_repository: @provider_repository,
                                          auth_log_repository: @auth_log_repository)
          authenticate_result = authenticate.call(**params[:session], uuid: uuid, client: remote_ip)

          if authenticate_result.failure?
            halt 422, JSON.generate({
              code: 422,
              message: authenticate_result.errors.first || 'ログインに失敗しました。',
            })
          end

          # セッション情報を保存
          session[:user_id] = authenticate_result.user.id
          self.status = 201
          self.body = JSON.generate({
            uuid: session[:uuid],
            username: authenticate_result.user.name,
            display_name: authenticate_result.user.display_name,
          })
        end
      end
    end
  end
end
