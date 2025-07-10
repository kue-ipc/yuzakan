# frozen_string_literal: true

module API
  module Actions
    module Users
      module Password
        class Create < API::Action
          security_level 3

          params do
            required(:user_id).filled(:name, max_size?: 255)
          end

          def initialize(service_repository: ServiceRepository.new,
            user_repository: UserRepository.new,
            config_repository: ConfigRepository.new,
            **opts)
            super
            @service_repository ||= service_repository
            @user_repository ||= user_repository
            @config_repository ||= config_repository
          end

          def handle(_request, _response)
            halt_json 400, errors: [params.errors] unless params.valid?

            reset_password = ResetPassword.new(service_repository: @service_repository,
              config_repository: @config_repository)
            result = reset_password.call({username: params[:user_id]})

            if result.failure?
              halt_json(422,
                errors: merge_errors(result.errors))
            end

            # @mailer&.deliver(**mailer_params, result: result)

            # mailer_params = {
            #   user: mail_user,
            #   config: @config,
            #   by_user: by_user,
            #   action: 'パスワードリセット',
            #   description: 'パスワードをリセットしました。',
            # }

            self.status = 200
            self.body = generate_json({password: result.password})
          end

          def handle_google(_request, _response)
            service = ServiceRepository.new.first_google_with_adapter

            result = ResetPassword.new(user: current_user,
              client: client,
              config: current_config,
              services: [service])
              .call(params.get(:google_password_create))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = "Google アカウントのパスワードリセットに失敗しました。"
              redirect_to routes.path(:google)
            end

            @user = result.user_datas[service.name]
            @password = result.password

            flash[:success] = "Google アカウントのパスワードをリセットしました。"
          end
        end
      end
    end
  end
end
