# frozen_string_literal: true

require "zxcvbn"

module API
  module Actions
    module Users
      module Password
        class Update < API::Action
          include Dry::Monads[:result]

          include Deps[
            "services.authenticate",
            "services.change_password",
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
            in Success(_service)
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

            # TODO: パスワードのチェック(未整理)
            password_size = request.params[:password].size
            if response[:current_config].password_min_size&.>(password_size)
              param_errors[:name] = [t("errors.min_size?", num: response[:current_config].password_min_size)]
            elsif response[:current_config].password_max_size&.<(password_size)
              param_errors[:name] = [t("errors.max_size?", num: response[:current_config].password_max_size)]
            end

            if request.params[:password] !~ /\A[\u0020-\u007e]*\z/ ||
                !!(response[:current_config].password_prohibited_chars&.chars || []).intersect?(request.params[:password].chars)
              param_errors[:name] ||= []
              param_errors[:name] << t("errors.valid_chars?")
            end

            password_types = [/[0-9]/, /[a-z]/, /[A-Z]/,
              /[^0-9a-zA-Z]/,].select do |reg|
              reg.match(request.params[:password])
            end.size
            if response[:current_config].password_min_types&.> password_types
              param_errors[:name] ||= []
              param_errors[:name] << t("errors.min_types?",
                num: response[:current_config].password_min_types)
            end

            dict = response[:current_config].password_extra_dict +
              [
                response[:current_user].name,
                response[:current_user].label&.split,
                response[:current_user].email,
                response[:current_user].email&.split("@"),
                request.params[:current_password],
              ].flatten.compact

            password_score = Zxcvbn.test(request.params[:password], dict).score
            if response[:current_config].password_min_score&.>(password_score)
              param_errors[:name] ||= []
              param_errors[:name] << t("errors.strong_password?")
            end

            # パスワードの変更
            case change_password.call(username, new_password)
            in Success(services)
              if services.empty?
                response.flash[:warn] = t("messages.action.no_services", action: t("api.user_password.actions.update"))
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

            # TODO: メール通知
            # if current_user.email
            #   @user_notify.deliver(
            #     user: current_user,
            #     config: response[:current_config],
            #     by_user: :self,
            #     action: "パスワード変更",
            #     description: "アカウントのパスワードを変更しました。")
            # end

            response[:user_password] = {password: new_password, services: services.map(&:name)}
            response.render(show_view)
          end
        end
      end
    end
  end
end
