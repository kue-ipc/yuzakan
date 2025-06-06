# frozen_string_literal: true

module API
  module Actions
    module Users
      module Password
        class Update < API::Action
          include Dry::Monads[:result]

          include Deps[
            "providers.authenticate",
            "providers.change_password",
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
                {password_confirmation: [t("errors.eql?", left: t("api.user_password.params.password"))]}
              halt_json request, response, 422
            end

            username = response[:current_user].name
            current_password = request.params[:password_current]
            new_password = request.params[:password]

            # 現在のパスワードの確認
            case authenticate.call(username, current_password)
            in Success(_provider)
              # do next
            in Failure[:error, error]
              response.flash[:error] = error
              halt_json request, response, 500
            in Failure[:failure, message]
              response.flash[:invalid] =
                {password_current: [t("errors.eql?", left: t("api.user_password.params.password_current"))]}
              halt_json request, response, 422
            in Failure[level, message]
              response.flash[level] = message
              halt_json request, response, 422
            end

            # パスワードの変更
            case change_password.call(username, new_password)
            in Success(providers)
              if providers.empty?
                response.flash[:warn] = t("messages.action.no_providers", action: t("api.user_password.actions.update"))
              else
                response.flash[:success] = t("messages.action.success", action: t("api.user_password.actions.update"))
              end
            in Failure[:error, error]
              response.flash[:error] = error
              halt_json request, response, 500
            in Failure[level, message]
              response.flash[level] = message
              halt_json request, response, 422
            end

            response[:user_password] = {password: new_password, providers: providers.map(&:name)}
            response.render(show_view)
          end
        end
      end
    end
  end
end
