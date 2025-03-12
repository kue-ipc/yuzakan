# frozen_string_literal: true

module API
  module Actions
    module Session
      class Create < API::Action
        include Deps[
          "repos.auth_log_repo",
          "providers.authenticate",
        ]

        security_level 0

        params do
          required(:username).value(Yuzakan::Types::NameString, max_size?: 255)
          required(:password).filled(:string, max_size?: 255)
        end

        # def initialize(user_repository: UserRepository.new,
        #   provider_repository: ProviderRepository.new,
        #   auth_log_repository: AuthLogRepository.new,
        #   group_repository: GroupRepository.new,
        #   member_repository: MemberRepository.new,
        #   **opts)
        #   super
        #   @user_repository ||= user_repository
        #   @provider_repository ||= provider_repository
        #   auth_log_repo ||= auth_log_repository
        #   @group_repository ||= group_repository
        #   @member_repository ||= member_repository
        # end

        def handle(request, response)
          unless request.params.valid?
            halt_json 422, errors: [only_first_errors(params.errors)]
          end

          unless response[:current_network].trusted
            halt_json 403, errors: [I18n.t("session.errors.deny_network")]
          end

          if response[:current_user]
            redirect_to_json routes.path(:session), status: 303
          end

          auth_log_params = {
            uuid: response[:current_uuid],
            client: request.ip,
            username: request.params[:username],
          }

          failure_count = 0

          # 10 minutes
          auth_log_repo.recent_by_username(request.params[:username], 600)
            .each do |auth_log|
            case auth_log.result
            when "success", "recover"
              break
            when "failure"
              failure_count += 1
            end
          end

          if failure_count >= 5
            auth_log_repo.create(**auth_log_params, result: "reject")
            halt_json 403, errors: [I18n.t("session.errors.too_many_failure")]
          end

          auth_result = authenticate.call(params)
          case auth_result
          in Success(provider)
          in Failure[:invalid, validation]
          end
          if auth_result.failure?
            auth_log_repo.create(**auth_log_params, result: "error")
            halt_json 500, errors: auth_result.errors
          end

          provider = auth_result.provider
          if provider.nil?
            auth_log_repo.create(**auth_log_params, result: "failure")
            halt_json 422, errors: [I18n.t("session.errors.incorrect")]
          end

          auth_log_repo.create(**auth_log_params,
            result: "success:#{provider.name}")

          user = @user_repository.find_by_name(params[:username])
          if user.nil?
            sync_user = SyncUser.new(provider_repository: @provider_repository,
              user_repository: @user_repository,
              group_repository: @group_repository,
              member_repository: @member_repository)
            sync_user_result = sync_user.call({username: params[:username]})
            if sync_user_result.failure?
              halt_json 500,
                errors: sync_user_result.errors
            end

            user = sync_user_result.user
          end

          # 使用禁止を確認
          if user.prohibited
            auth_log_repo.create(**auth_log_params, result: "prohibited")
            halt_json 403, errors: [I18n.t("session.errors.prohibited")]
          end

          # クリアランスレベルを確認
          if user.clearance_level.zero?
            auth_log_repo.create(**auth_log_params,
result: "no_clearance")
            halt_json 403, errors: [I18n.t("session.errors.no_clearance")]
          end

          # セッション情報を保存
          session[:user_id] = user.id
          session[:created_at] = current_time
          session[:updated_at] = current_time

          self.status = 201
          self.body = generate_json({
            uuid: session[:uuid],
            current_user: user,
            created_at: current_time,
            updated_at: current_time,
            deleted_at: current_time + current_config.session_timeout,
          })
        end
      end
    end
  end
end
