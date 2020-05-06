# frozen_string_literal: true

module Legacy
  module Controllers
    module User
      module Password
        class Update
          include Legacy::Action

          def call(params)
            @change_password = ChangePassword.new(config: current_config,
                                                  user: current_user,
                                                  client: remote_ip)
            result = @change_password.call(params[:user][:password])

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = 'パスワードを変更することができませんでした。'
              redirect_to routes.path(:edit_user_password)
            end

            flash[:success] = 'パスワードを変更しました。'
          end
        end
      end
    end
  end
end
