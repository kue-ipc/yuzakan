# frozen_string_literal: true

module Web
  module Controllers
    module User
      module Password
        class Update
          include Web::Action

          def initialize
            @change_password = PasswordChange.new
          end

          def call(params)
            result = @change_password.call(
              username: current_user.name,
              password_current: params[:user][:password_current],
              password: params[:user][:password],
              password_confirmation: params[:user][:password_confirmation],
            )
            if result.failure?
              flash[:errors] = result.errors
              redirect_to routes.path(:edit_user_password)
            else
              flash[:successes] ||= []
              flash[:successes] << 'パスワードを変更しました。'
            end
          end
        end
      end
    end
  end
end
