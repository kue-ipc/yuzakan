# frozen_string_literal: true

module API
  module Actions
    module Auth
      class Create < API::Action
        include Dry::Monads[:result]

        include Deps[
          "repos.auth_log_repo",
          "repos.user_repo",
          "management.sync_user",
          "providers.authenticate",
          "settings",
          show_view: "views.auth.show"
        ]

        security_level 0
        required_authentication false

        params do
          required(:username).filled(:name, max_size?: 255)
          required(:password).filled(:string, max_size?: 255)
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
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
            response.flash[:info] = t("messages.already_authenticated")
            redirect_to_json(request, response, routes.path(:api_auth), status: 303)
          end

          # 信頼さていないネットワークからのログイン
          unless settings.auth_untrusted || response[:current_network].trusted
            auth_log_repo.create(**auth_log_params, result: "reject")
            response.flash[:error] = t("errors.deny_network")
            halt_json request, response, 403
          end

          # 失敗回数確認
          if failures_over?(username,
            count: response[:current_config].auth_failure_limit,
            period: response[:current_config].auth_failure_duration)
            auth_log_repo.create(**auth_log_params, result: "reject")
            response.flash[:error] = t("errors.too_many_authentictaion_failure")
            halt_json request, response, 403
          end

          # 認証実行
          case authenticate.call(username, password)
          in Success(provider)
            # do next
          in Failure[:error, error]
            auth_log_repo.create(**auth_log_params, result: "error")
            response.flash[:error] = error
            halt_json request, response, 500
          in Failure[level, message]
            # タイミング攻撃防止
            waiting_time = response[:current_time] - Time.now + response[:current_config].auth_failure_waiting
            sleep waiting_time if waiting_time.positive?
            auth_log_repo.create(**auth_log_params, result: "failure")
            response.flash[level] = message
            halt_json request, response, 422
          end

          # ユーザー同期
          user = user_repo.get(username)
          if user.nil?
            case sync_user.call(username)
            in Success(user)
              # do next
            in Failure[:error, error]
              auth_log_repo.create(**auth_log_params, result: "sync_error")
              response.flash[:error] = error
              halt_json request, response, 500
            in Failure[level, message]
              auth_log_repo.create(**auth_log_params, result: "failure")
              response.flash[level] = message
              halt_json request, response, 422
            end
          end

          # 使用禁止を確認
          if user.prohibited
            auth_log_repo.create(**auth_log_params, result: "prohibited")
            response.flash[:warn] = t("errors.prohibited_user")
            halt_json request, response, 403
          end

          # クリアランスレベルを確認
          unless settings.auth_guest || user.clearance_level.positive?
            auth_log_repo.create(**auth_log_params, result: "no_clearance")
            response.flash[:warn] = t("errors.geust_user")
            halt_json request, response, 403
          end

          # セッション情報を保存
          response.session[:user] = user.name

          auth_log_repo.create(**auth_log_params, result: "success", provider: provider.name)
          response.flash[:success] = t("messages.action.success", action: t("actions.login"))
          response.status = :created
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
