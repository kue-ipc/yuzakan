module Api
  module Controllers
    module Session
      class Create
        include Api::Action

        security_level 0

        params do
          required(:session).schema do
            required(:username).filled(:str?, size?: 1..255)
            required(:password).filled(:str?, size?: 1..255)
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
            halt 400
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
                messages: {success: 'ログインしました。'},
                redirect_to: Web.routes.path(:root),
              }
            else
              self.status = 422
              {
                result: 'failure',
                messages: {
                  errors: authenticate_result.errors,
                  failure: 'ログインに失敗しました。',
                },
              }
            end
          self.body = JSON.generate(@result)
        end
      end
    end
  end
end
