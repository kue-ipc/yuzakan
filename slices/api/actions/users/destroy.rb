# frozen_string_literal: true

module API
  module Actions
    module Users
      class Destroy < API::Action
        security_level 4

        contract do
          params do
            required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)
          end

          rule(:id).validate(:name)
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

          @user_repository.delete(@user.id)

          self.body = user_json
        end
      end
    end
  end
end
