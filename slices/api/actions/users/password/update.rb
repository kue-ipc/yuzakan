# frozen_string_literal: true

module API
  module Actions
    module Users
      module Password
        class Update < API::Action
          # TODO: confirmationはいらないと思う。
          params do
            required(:password_current).maybe(:name, max_size?: 255)
            required(:password).filled(:string, max_size?: 255).confirmation
            required(:password_confirmation).filled(:string, max_size?: 255)
          end

          def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
            unless request.params.valid?
              response.flash[:invalid] = request.params.errors
              halt_json request, response, 422
            end



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
end
