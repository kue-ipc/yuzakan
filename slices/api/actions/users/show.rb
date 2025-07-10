# frozen_string_literal: true

module API
  module Actions
    module Users
      class Show < API::Action
        include Deps[
          "repos.service_repo",
          "repos.user_repo"
        ]

        security_level 2

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          halt_json 400, errors: [params.errors] unless params.valid?

          @name = params[:id]
          load_user

          halt_json 404 if @user.nil?
          self.body = user_json
        end

        private def call_interacttor(interactor, params)
          result = interactor.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def sync_user(params)
          @sync_user ||= SyncUser.new(service_repository: @service_repository,
            user_repository: @user_repository,
            group_repository: @group_repository,
            member_repository: @member_repository)
          call_interacttor(@sync_user, params)
        end

        private def service_create_user(params)
          @service_create_user ||= ServiceCreateUser.new(service_repository: @service_repository)
          call_interacttor(@service_create_user, params)
        end

        private def service_read_user(params)
          @service_read_user ||= ServiceReadUser.new(service_repository: @service_repository)
          call_interacttor(@service_read_user, params)
        end

        private def service_update_user(params)
          @service_update_user ||= ServiceUpdateUser.new(service_repository: @service_repository)
          call_interacttor(@service_update_user, params)
        end

        private def service_delete_user(params)
          @service_delete_user ||= ServiceDeleteUser.new(service_repository: @service_repository)
          call_interacttor(@service_delete_user, params)
        end

        private def service_lock_user(params)
          @service_lock_user ||= ServiceLockUser.new(service_repository: @service_repository)
          call_interacttor(@service_lock_user, params)
        end

        private def service_unlock_user(params)
          @service_unlock_user ||= ServiceUnlockUser.new(service_repository: @service_repository)
          call_interacttor(@service_unlock_user, params)
        end

        private def generate_password(params = {})
          @generate_password ||= GeneratePassword.new(config_repository: @config_repository)
          call_interacttor(@generate_password, params)
        end

        private def load_user
          result = sync_user({username: @name})
          @user = result.user
          @attrs = result.data[:attrs]
          @services = result.services
        end

        private def user_json(**data)
          hash = convert_for_json(@user, assoc: true).dup
          hash[:services] = @services unless @services.nil?
          hash[:attrs] = @attrs unless @attrs.nil?
          hash.merge!(data)
          generate_json(hash)
        end
      end
    end
  end
end
