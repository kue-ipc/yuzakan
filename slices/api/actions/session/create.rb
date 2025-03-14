# frozen_string_literal: true

module API
  module Actions
    module Session
      class Create < API::Action
        include Deps[
          "repos.auth_log_repo",
          "repos.user_repo",
          "mgmt.sync_user",
          "providers.authenticate",
        ]

        security_level 0

        params do
          required(:username).filled(Yuzakan::Types::NameString, max_size?: 255)
          required(:password).filled(:string, max_size?: 255)
        end

        def handle(request, response)
          unless request.params.valid?
            halt_json 422, errors: [only_first_errors(params.errors)]
          end
          username = request.params[:username]
          password = request.params[:password]

          if response[:current_user]
            # do nothing
            redirect_to_json routes.path(:session), status: 303
          end

          auth_log_params = {
            uuid: response[:current_uuid],
            client: request.ip,
            username: username,
          }

          unless response[:current_network].trusted
            auth_log_repo.create(**auth_log_params, result: "reject")
            halt_json 403, errors: [I18n.t("session.errors.deny_network")]
          end

          # TODO: パラメーターとして設定できるようにする
          # 600秒の間に5回以上失敗した場合、拒否する。
          if count_failure(username, 600) >= 5
            auth_log_repo.create(**auth_log_params, result: "reject")
            halt_json 403, errors: [I18n.t("session.errors.too_many_failure")]
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

          user = user_repo.find_by_name(username)
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
            halt_json 403, errors: [I18n.t("session.errors.prohibited")]
          end

          # クリアランスレベルを確認
          if user.clearance_level.zero?
            auth_log_repo.create(**auth_log_params, result: "no_clearance")
            halt_json 403, errors: [I18n.t("session.errors.no_clearance")]
          end

          # セッション情報を保存
          session[:user_id] = user.id
          session[:created_at] = current_time
          session[:updated_at] = current_time

          auth_log_repo.create(**auth_log_params, result: "success",
            provider: provider.name)
          response.status = :created
          response.body = generate_json({
            uuid: session[:uuid],
            current_user: user,
            created_at: current_time,
            updated_at: current_time,
            deleted_at: current_time + current_config.session_timeout,
          })
        end

        private def count_failure(usarname, time)
          failure_count = 0
          auth_log_repo.recent_by_username(username, time)
            .each do |auth_log|
            case auth_log.result
            when "success", "recover"
              break
            when "failure"
              failure_count += 1
            end
          end
          failure_count
        end
      end
    end
  end
end
