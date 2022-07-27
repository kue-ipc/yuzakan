module Api
  module Controllers
    module Users
      module Password
        class Create
          include Api::Action

          security_level 3

          def initialize(provider_repository: ProviderRepository.new,
                         user_repository: UserRepository.new,
                         **opts)
            super
            @provider_repository ||= provider_repository
            @user_repository ||= user_repository
          end

          def call(params)
            reset_password = ResetPassword.new(
              provider_repository: @provider_repository)
            result = reset_password.call(params)

            halt_json(422, errors: merge_errors(result.errors)) if result.failure?

            # @mailer&.deliver(**mailer_params, result: result)

            # mailer_params = {
            #   user: mail_user,
            #   config: @config,
            #   by_user: by_user,
            #   action: 'パスワードリセット',
            #   description: 'パスワードをリセットしました。',
            # }

            self.status = 201
            headers['Location'] = routes.user_path(result.user.id)
            self.body = generate_json({
              username: result.username,
              password: result.password,
            })
          end
        end
      end
    end
  end
end
