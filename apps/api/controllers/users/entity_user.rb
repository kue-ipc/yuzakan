# frozen_string_literal: true

require_relative './interactor_user'

module Api
  module Controllers
    module Users
      module EntityUser
        include InteractorUser

        def initialize(user_repository: UserRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
        end

        private def load_user(sync: false)
          if sync
            result = sync_user({username: @name})
            @user = result.user
            @attrs = result.data[:attrs]
            @providers = result.providers
          else
            @user = @user_repository.find_with_groups_by_name(@name)
            @attrs = nil
            @providers = nil
          end
        end

        private def user_json
          hash = convert_for_json(@user, assoc: true).dup
          hash[:providers] = @providers unless @providers.nil?
          hash[:attrs] = @attrs unless @attrs.nil?
          generate_json(hash)
        end
      end
    end
  end
end
