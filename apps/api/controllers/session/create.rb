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

        expose :result

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       auth_log_repository: AuthLogRepository.new, **opts)
          super(user_repository: user_repository, **opts)
          @provider_repository = provider_repository
          @auth_log_repository = auth_log_repository
        end

        def call(params)
          unless params.valid?
            halt 400, JSON.generate({
              result: 'error',
              message: '不正なパラメーターです。',
              errors: params.error_messages,
            })
          end

          authenticate = Authenticate.new(user_repository: @user_repository,
                                          provider_repository: @provider_repository,
                                          auth_log_repository: @auth_log_repository)
          authenticate_result = authenticate.call(**params[:session], uuid: uuid, client: remote_ip)

          @result =
            if authenticate_result.successful?
              # セッション情報を保存
              session[:user_id] = authenticate_result.user.id

              {
                result: 'success',
                message: 'ログインしました。',
              }
            else
              self.status = 422
              {
                result: 'failure',
                message: 'ログインに失敗しました。',
                errors: authenticate_result.errors,
              }
            end
          self.body = JSON.generate(@result)
        end
      end
    end
  end
end
