# frozen_string_literal: true

module API
  module Actions
    module Users
      module Lock
        class Destroy < API::Action
          security_level 3

          class Params < Hanami::Action::Params
            predicates NamePredicates
            messages :i18n

            params do
              required(:user_id).filled(:str?, :name?, max_size?: 255)
            end
          end

          def initialize(provider_repository: ProviderRepository.new,
            **opts)
            super
            @provider_repository ||= provider_repository
          end

          def handle(_request, _response)
            halt_json 400, errors: [params.errors] unless params.valid?

            result = call_interacttor(ProviderUnlockUser.new(provider_repository: @provider_repository),
              {username: params[:user_id]})

            providers = result.providers.compact.transform_values { |v| {locked: !v} }
            self.status = 200
            self.body = generate_json({providers: providers})
          end

          def handle_google(_request, _response)
            provider = ProviderRepository.new.first_google_with_adapter

            result = UnlockUser.new(
              user: current_user,
              client: client,
              config: current_config,
              providers: [provider]).call(params.get(:google_lock_destroy))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = "Google アカウントのロック解除に失敗しました。"
              redirect_to routes.path(:google)
            end

            @user = result.user_datas[provider.name]
            @password = result.password

            flash[:success] = if @password
                                "Google アカウントのロックを解除し、パスワードをリセットしました。"
                              else
                                "Google アカウントのロックを解除しました。"
                              end
          end
        end
      end
    end
  end
end
