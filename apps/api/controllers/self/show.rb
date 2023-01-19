# frozen_string_literal: true

require_relative '../users/user_interactor'

module Api
  module Controllers
    module Self
      class Show
        include Api::Action
        include Users::UserInteractor

        def initialize(provider_repository: ProviderRepository.new,
                       **opts)
          super(**opts)
          @provider_repository = provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @username = current_user.name
          set_sync_user

          halt_json 404 unless @user

          self.body = user_json
        end
      end
    end
  end
end
