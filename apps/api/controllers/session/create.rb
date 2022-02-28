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

          auth_log_params = {
            uuid: uuid,
            client: client,
            username: params[:username],
          }

          failure_count = 0

          # 10 minutes
          @auth_log_repository.recent_by_username(params[:username], 600).each do |auth_log|
            case auth_log.result
            when 'success', 'recover'
              break
            when 'failure'
              failure_count += 1
            end
          end

          if failure_count >= 5
            @auth_log_repository.create(**auth_log_params, result: 'reject')
            halt_json 403, '時間あたりのログイン試行が規定の回数を超えたため、現在ログインが禁止されています。' \
                           'しばらく待ってから再度ログインを試してください。'
          end

          authenticate = Authenticate.new(provider_repository: @provider_repository)
          authenticate_result = authenticate.call(params)

          if authenticate_result.failure?
            @auth_log_repository.create(**auth_log_params, result: 'error')
            halt_json 500, 'エラーが発生しました。', errors: authenticate_result.errors
          end

          userdata = authenticate_result.userdatas.values.first

          if userdata.nil?
            @auth_log_repository.create(**auth_log_params, result: 'failure')
            halt_json 422, 'ユーザー名またはパスワードが違います。'
          end

          @auth_log_repository.create(**auth_log_params, result: 'success')
          user = create_or_upadte_user(userdata)

          # セッション情報を保存
          session[:user_id] = user.id
          session[:created_at] = current_time
          session[:updated_at] = current_time

          self.status = 201
          self.body = generate_json({
            username: user.name,
            display_name: user.display_name,
            created_at: current_time,
            updated_at: current_time,
          })
        end

        private def create_or_upadte_user(userdata)
          name = userdata[:name]
          display_name = userdata[:display_name] || userdata[:name]
          email = userdata[:email]
          user = @user_repository.find_by_name(name)
          if user.nil?
            @user_repository.create(name: name, display_name: display_name, email: email)
          elsif user.display_name != display_name || user.email != email
            @user_repository.update(user.id, display_name: display_name, email: email)
          else
            user
          end
        end
      end
    end
  end
end
