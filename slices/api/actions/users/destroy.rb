# frozen_string_literal: true

module API
  module Actions
    module Users
      class Destroy < API::Action
        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)
          optional(:permanent).maybe(:bool?)
        end

        def initialize(user_repository: UserRepository.new,
          **opts)
          super
          @user_repository ||= user_repository
        end

        def handle(_request, _response)
          unless @user.deleted?
            service_delete_user({username: @name}) unless @user.deleted?
            sync_user({username: @name})
          end

          @user_repository.delete(@user.id) if params[:permanent]

          self.body = user_json
        end
      end
    end
  end
end
