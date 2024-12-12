# frozen_string_literal: true

require_relative "../users/entity_user"

module API
  module Actions
    module Self
      class Show < API::Action
        include Users::EntityUser

        def initialize(provider_repository: ProviderRepository.new,
                       **opts)
          super
          @provider_repository = provider_repository
        end

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          @name = current_user.name
          load_user
          halt_json 404 unless @user

          self.body = user_json
        end
      end
    end
  end
end
