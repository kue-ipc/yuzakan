# frozen_string_literal: true

module Web
  module Controllers
    module User
      module Password
        class Update
          include Web::Action

          def call(params)
            @change_password = ChangePassword.new(config: current_config,
                                                  user: current_user,
                                                  client: remote_ip)
            result = @change_password.call(params[:user][:password])
            if result.failure?
              flash[:errors] = result.errors
              flash[:errors] << 'パスワード変更に失敗しました。'
              redirect_to routes.path(:edit_user_password)
            else
              flash[:successes] = ['パスワードを変更しました。']
            end
          end
        end
      end
    end
  end
end
