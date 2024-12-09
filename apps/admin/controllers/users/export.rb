# frozen_string_literal: true

module Admin
  module Controllers
    module Users
      class Export
        include Admin::Action

        security_level 5

        def initialize(user_repository: UserRepository.new, **opts)
          super
          @user_repository ||= user_repository
        end

        expose :users

        def call(params)
          @users = @user_repository.all
        end
      end
    end
  end
end
