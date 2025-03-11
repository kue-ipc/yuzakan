# frozen_string_literal: true

require_relative "interactor_user"

module API
  module Actions
    module Users
      module EntityUser
        include InteractorUser

        private def load_user
          result = sync_user({username: @name})
          @user = result.user
          @attrs = result.data[:attrs]
          @providers = result.providers
        end

        private def user_json(**data)
          hash = convert_for_json(@user, assoc: true).dup
          hash[:providers] = @providers unless @providers.nil?
          hash[:attrs] = @attrs unless @attrs.nil?
          hash.merge!(data)
          generate_json(hash)
        end
      end
    end
  end
end
