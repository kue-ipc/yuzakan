# frozen_string_literal: true

module User
  module Actions
    module Password
      class Update < User::Action
        expose :data

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          result = ProviderChangePassword.new(config: current_config,
            user: current_user,
            client: client)
            .call(params[:user][:password])

          case format
          when :html
            if result.successful?
              flash[:success] = "パスワードを変更しました。"
            else
              flash[:errors] = result.errors
              flash[:failure] = "パスワードを変更することができませんでした。"
              redirect_to routes.path(:edit_user_password)
            end
          when :json
            @data = if result.successful?
                      {
                        result: "success",
                        messages: {
                          success: "パスワードを変更しました。",
                        },
                      }
                    else
                      {
                        result: "failure",
                        messages: {
                          errors: result.errors,
                          failure: "パスワードを変更することができませんでした。",
                        },
                      }
                    end
          end
        end
      end
    end
  end
end
