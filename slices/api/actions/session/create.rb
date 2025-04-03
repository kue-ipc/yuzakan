# frozen_string_literal: true

module API
  module Actions
    module Session
      class Create < API::Action
        include Deps[
          "repos.auth_log_repo",
          "repos.user_repo",
          "management.sync_user",
          "providers.authenticate",
        ]

        params do
          required(:username).filled(Yuzakan::Types::NameString, max_size?: 255)
          required(:password).filled(:string, max_size?: 255)
        end

        security_level 0
        private def authenticate!(_req, _res) = nil

        def handle(req, res)
          unless req.params.valid?
            halt_json 422, errors: [req.params.errors]
            # halt_json 422, errors: [only_first_errors(req.params.errors)]
          end
          username = req.params[:username]
          password = req.params[:password]

          if res[:current_user]
            # redirect
            redirect_to_json(res, routes.path(:api_session), status: 303)
          end

          auth_log_params = {
            uuid: res[:current_uuid],
            client: res[:current_client],
            user: username,
          }

          unless res[:current_network].trusted
            auth_log_repo.create(**auth_log_params, result: "reject")
            halt_json 403, errors: [t.call("session.errors.deny_network")]
          end

          if failures_over?(username,
            count: res[:current_config].session_failure_limit,
            period: res[:current_config].session_failure_duration)
            auth_log_repo.create(**auth_log_params, result: "reject")
            halt_json 403, errors: [t.call("session.errors.too_many_failure")]
          end

          case authenticate.call(username, password)
          in Success(provider)
            # do next
          in Failure[:failure, message]
            auth_log_repo.create(**auth_log_params, result: "failure")
            halt_json 422, errors: [message]
          in Failure[:invalid, validation]
            auth_log_repo.create(**auth_log_params, result: "failure")
            halt_json 422, errors: [validation]
          in Failure[:error, error]
            auth_log_repo.create(**auth_log_params, result: "error")
            halt_json 500, errors: [error]
          end

          user = user_repo.get(username)
          if user.nil?
            case sync_user.call(username)
            in Success(user)
              # do next
            in Failure[:error, error]
              auth_log_repo.create(**auth_log_params, result: "sync_error")
              halt_json 500, errors: [error]
            in Failure[_, message]
              auth_log_repo.create(**auth_log_params, result: "sync_failure")
              halt_json 422, errors: [message]
            end
          end

          # 使用禁止を確認
          if user.prohibited
            auth_log_repo.create(**auth_log_params, result: "prohibited")
            halt_json 403, errors: [t.call("session.errors.prohibited")]
          end

          # クリアランスレベルを確認
          if user.clearance_level.zero?
            auth_log_repo.create(**auth_log_params, result: "no_clearance")
            halt_json 403, errors: [t.call("session.errors.no_clearance")]
          end

          # セッション情報を保存
          res.session[:user] = user.name

          auth_log_repo.create(**auth_log_params, result: "success",
            provider: provider.name)
          res.status = :created
          res.body = generate_json({
            uuid: res.session[:uuid],
            user: res.session[:user],
            created_at: res.session[:created_at],
            updated_at: res.session[:updated_at],
          })
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
