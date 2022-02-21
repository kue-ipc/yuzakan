require 'time'

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
            self.body = JSON.generate({
              code: 303,
              location: routes.path(:session),
              message: '既にログインしています。'
            })
            redirect_to routes.path(:session), status: 303
          end

          halt_json(400, 'パラメーターが不正です。', errors: params.error_messages) unless params.valid?

          authenticate = Authenticate.new(user_repository: @user_repository,
                                          provider_repository: @provider_repository,
                                          auth_log_repository: @auth_log_repository)
          authenticate_result = authenticate.call(**params[:session], uuid: uuid, client: remote_ip)

          halt_json(422, authenticate_result.errors.first || 'ログインに失敗しました。') if authenticate_result.failure?

          # セッション情報を保存
          session[:user_id] = authenticate_result.user.id
          session[:created_at] = current_time
          session[:updated_at] = current_time

          self.status = 201
          self.body = JSON.generate({
            username: authenticate_result.user.name,
            display_name: authenticate_result.user.display_name,
            created_at: current_time.iso8601,
            updated_at: current_time.iso8601,
          })
        end
      end
    end
  end
end
