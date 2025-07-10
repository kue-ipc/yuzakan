# frozen_string_literal: true

module API
  module Actions
    module Users
      module Lock
        class Destroy < API::Action
          security_level 3

          params do
            required(:user_id).filled(:name, max_size?: 255)
          end

          def initialize(service_repository: ServiceRepository.new,
            **opts)
            super
            @service_repository ||= service_repository
          end

          def handle(_request, _response)
            halt_json 400, errors: [params.errors] unless params.valid?

            result = call_interacttor(ServiceUnlockUser.new(service_repository: @service_repository),
              {username: params[:user_id]})

            services = result.services.compact.transform_values { |v| {locked: !v} }
            self.status = 200
            self.body = generate_json({services: services})
          end

          def handle_google(_request, _response)
            service = ServiceRepository.new.first_google_with_adapter

            result = UnlockUser.new(
              user: current_user,
              client: client,
              config: current_config,
              services: [service]).call(params.get(:google_lock_destroy))

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = "Google アカウントのロック解除に失敗しました。"
              redirect_to routes.path(:google)
            end

            @user = result.user_datas[service.name]
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
