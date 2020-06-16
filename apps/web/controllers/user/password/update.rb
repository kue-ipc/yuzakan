# frozen_string_literal: true

module Web
  module Controllers
    module User
      module Password
        class Update
          include Web::Action
          expose :data

          def call(params)
            @change_password = ChangePassword.new(config: current_config,
                                                  user: current_user,
                                                  client: remote_ip)
            result = @change_password.call(params[:user][:password])

            case format
            when :html
              if result.successful?
                flash[:success] = 'パスワードを変更しました。'
              else
                flash[:errors] = result.errors
                flash[:failure] = 'パスワードを変更することができませんでした。'
                redirect_to routes.path(:edit_user_password)
              end
            when :json
              if result.successful?
                @data = {
                  result: 'success',
                  messages: {
                    success: 'パスワードを変更しました。',
                  },
                }
              else
                @data = {
                  result: 'failure',
                  messages: {
                    errors: result.errors,
                    failure: 'パスワードを変更することができませんでした。',
                  },
                }
              end
            end
          end
        end
      end
    end
  end
end
