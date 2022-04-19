module Api
  module Controllers
    module Session
      class Create
        include Api::Action

        security_level 0

        params do
        end

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:username).filled(:str?, :name?, max_size?: 255)
            required(:password).filled(:str?, max_size?: 255)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       auth_log_repository: AuthLogRepository.new, **opts)
          super
          @user_repository ||= user_repository
          @provider_repository ||= provider_repository
          @auth_log_repository ||= auth_log_repository
        end

        def call(params)
          unless params.valid?
            halt_json 400, errors: [only_first_errors(params.errors), I18n.t('session.errors.invalid_params')]
          end

          halt_json 403, errors: [I18n.t('session.errors.deny_network')] unless allowed_user_networks?

          redirect_to_json routes.path(:session), status: 303 if current_user

          auth_log_params = {
            uuid: uuid,
            client: client,
            username: params[:username],
          }

          failure_count = 0

          # 10 minutes
          @auth_log_repository.recent_by_username(params[:username], 600).each do |auth_log|
            case auth_log.result
            when 'success', 'recover'
              break
            when 'failure'
              failure_count += 1
            end
          end

          if failure_count >= 5
            @auth_log_repository.create(**auth_log_params, result: 'reject')
            halt_json 403, errors: [I18n.t('session.errors.too_many_failure')]
          end

          authenticate = Authenticate.new(provider_repository: @provider_repository)
          authenticate_result = authenticate.call(params)

          if authenticate_result.failure?
            @auth_log_repository.create(**auth_log_params, result: 'error')
            halt_json 500, errors: authenticate_result.errors
          end

          provider = authenticate_result.provider
          if provider.nil?
            @auth_log_repository.create(**auth_log_params, result: 'failure')
            halt_json 422, errors: [I18n.t('session.errors.incorrect')]
          end

          @auth_log_repository.create(**auth_log_params, result: "success:#{provider.name}")

          user = @user_repository.find_by_name(params[:username])
          if user.nil?
            read_user = ReadUser.new(provider_repository: @provider_repository)
            read_user_result = read_user.call({username: params[:username]})

            halt_json 500, errors: read_user_result.errors if read_user_result.failure?

            userdata = read_user_result.userdatas
              .map { |data| data[:userdata] }
              .inject({}) { |result, item| item.merge(result) }
              .slice(:name, :display_name, :email)

            register_user = RegisterUser.new(user_repository: @user_repository)
            register_user_result = register_user.call(userdata)
            halt_json 500, errors: register_user_result.errors if register_user_result.failure?

            user = register_user_result.user
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

        # private def create_or_upadte_user(userdata)
        #   name = userdata[:name]
        #   display_name = userdata[:display_name] || userdata[:name]
        #   email = userdata[:email]
        #   user = @user_repository.find_by_name(name)
        #   if user.nil?
        #     @user_repository.create(name: name, display_name: display_name, email: email)
        #   elsif user.display_name != display_name || user.email != email
        #     @user_repository.update(user.id, display_name: display_name, email: email)
        #   else
        #     user
        #   end
        # end
      end
    end
  end
end
