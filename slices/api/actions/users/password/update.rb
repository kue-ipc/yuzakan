# frozen_string_literal: true

module API
  module Actions
    module Users
      module Password
        class Update < API::Action
          include Deps[
            show_view: "views.users.password.show"
          ]

          params do
            # NOTE: id is always "~" (current user)
            required(:id).value(eql?: "~")
            required(:password_current).filled(:password, max_size?: 255)
            required(:password).filled(:password, max_size?: 255)
            required(:password_confirmation).filled(:password, max_size?: 255)
          end

          def handle(request, response)
            unless request.params.valid?
              response.flash[:invalid] = request.params.errors
              halt_json request, response, 422
            end

            if request.params[:password] != request.params[:password_confirmation]
              response.flash[:invalid] =
                {password_confirmation: [t("errors.eql?", left: t("api.user_password.password"))]}
              halt_json request, response, 422
            end

            response[:user_password] = {password: request.params[:password]}
            response.render(show_view)

            # result = ProviderChangePassword.new(config: current_config,
            #   user: current_user,
            #   client: client)
            #   .call(params[:user][:password])

            # case format
            # when :html
            #   if result.successful?
            #     flash[:success] = "パスワードを変更しました。"
            #   else
            #     flash[:errors] = result.errors
            #     flash[:failure] = "パスワードを変更することができませんでした。"
            #     redirect_to routes.path(:edit_user_password)
            #   end
            # when :json
            #   @data = if result.successful?
            #             {
            #               result: "success",
            #               messages: {
            #                 success: "パスワードを変更しました。",
            #               },
            #             }
            #           else
            #             {
            #               result: "failure",
            #               messages: {
            #                 errors: result.errors,
            #                 failure: "パスワードを変更することができませんでした。",
            #               },
            #             }
            #           end
            # end
          end
        end
      end
    end
  end
end
