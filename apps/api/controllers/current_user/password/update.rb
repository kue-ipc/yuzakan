module Api
  module Controllers
    module CurrentUser
      module Password
        class Update
          include Api::Action

          def initialize(provider_repository: ProviderRepository.new,
                         user_notify: Mailers::UserNotify,
                         **opts)
            super(**opts)
            @provider_repository = provider_repository
            @user_notify = user_notify
          end

          def call(params)
            check_change_password = CheckChangePassword.new(connection_info, provider_repository: @provider_repository)

            check_result = check_change_password.call(params)

            halt_json 422, errors: check_result.errors if check_result.filure?

            change_password = ChangePassword.new(provider_repository: provider_repository)
            result = change_password.call(username: check_result.username, password: check_result.password)

            mailer_params = {
              user: current_user,
              config: current_config,
              by_user: :self,
              action: 'パスワード変更',
              description: 'アカウントのパスワードを変更しました。',
            }

            if result.failure?
              user_notify.deliver(**mailer_params, result: :error) if current_user.email
              halt_json 500, errors: result.errors
            end

            self.status = 204
          end
        end
      end
    end
  end
end
