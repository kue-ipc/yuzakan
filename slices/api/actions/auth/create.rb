# frozen_string_literal: true

module API
  module Actions
    module Auth
      class Create < API::Action
        include Deps[
          "repos.auth_log_repo",
          "repos.user_repo",
          "management.sync_user",
          "providers.authenticate",
          "settings",
          show_view: "views.auth.show",
        ]

        include Dry::Monads[:result]

        params do
          required(:username).filled(Yuzakan::Types::NameString, max_size?: 255)
          required(:password).filled(:string, max_size?: 255)
        end

        security_level 0
        required_authentication false

        def handle(request, response)
          unless request.params.valid?
            add_flash(request, response, :error, request.params.errors)
            halt_json 422
          end

          username = request.params[:username]
          password = request.params[:password]

          auth_log_params = {
            uuid: response[:current_uuid],
            client: response[:current_client],
            user: username,
          }

          # ログイン済みか確認
          if response[:current_user]
            auth_log_repo.create(**auth_log_params, result: "authenticated")
            add_flash(request, response, :info,
              t("messages.already_authenticated"))
            redirect_to_json(response, routes.path(:api_auth))
          end

          # 信頼さていないネットワークからのログイン
          unless setting.auth_untrust || response[:current_network].trusted
            auth_log_repo.create(**auth_log_params, result: "reject")
            add_flash(request, response, :error, t("errors.deny_network"))
            halt_json 403
          end

          # 失敗回数確認
          if failures_over?(username,
            count: response[:current_config].session_failure_limit,
            period: response[:current_config].session_failure_duration)
            auth_log_repo.create(**auth_log_params, result: "reject")
            add_flash(request, response, :error,
              t("errors.too_many_authentictaion_failure"))
            halt_json 403
          end

          # 認証実行
          case authenticate.call(username, password)
          in Success(provider)
            # do next
          in Failure[:error, error]
            auth_log_repo.create(**auth_log_params, result: "error")
            add_flash(request, response, :error, error)
            halt_json 500
          in Failure[level, message]
            auth_log_repo.create(**auth_log_params, result: "failure")
            add_flash(request, response, level, message)
            halt_json 422
          end

          # ユーザー同期
          user = user_repo.get(username)
          if user.nil?
            case sync_user.call(username)
            in Success(user)
              # do next
            in Failure[:error, error]
              auth_log_repo.create(**auth_log_params, result: "sync_error")
              add_flash(request, response, :error, error)
              halt_json 500
            in Failure[level, message]
              auth_log_repo.create(**auth_log_params, result: "failure")
              add_flash(request, response, level, message)
              halt_json 422
            end
          end

          # 使用禁止を確認
          if user.prohibited
            auth_log_repo.create(**auth_log_params, result: "prohibited")
            add_flash(request, response, :warn, t("errors.prohibited_user"))
            halt_json 403
          end

          # クリアランスレベルを確認
          unless setting.auth_guest || user.clearance_level.positive?
            auth_log_repo.create(**auth_log_params, result: "no_clearance")
            add_flash(request, response, :warn, t("errors.geust_user"))
            halt_json 403, errors: []
          end

          # セッション情報を保存
          response.session[:user] = user.name

          auth_log_repo.create(**auth_log_params, result: "success",
            provider: provider.name)
          add_flash(request, response, :sucess,
            t("messages.action.success", action: t("actions.login")))
          response.status = :created
          response[:status] = response.status
          response[:auth] = {username:}
          response.render(show_view)
        end

        private def failures_over?(username, count:, period:)
          count = count.to_i
          auth_log_repo.recent(username, period:, limit: count,
            includes: ["success", "failure", "recover"]).each do |auth_log|
            case auth_log.result
            in "success" | "recover"
              return false
            in "failure"
              count -= 1
            else
              # do nothing
            end
          end

          !count.positive?
        end
      end
    end
  end
end
