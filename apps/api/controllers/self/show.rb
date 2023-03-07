# frozen_string_literal: true

require_relative '../users/entity_user'

module Api
  module Controllers
    module Self
      class Show
        include Api::Action
        include Users::EntityUser

        def initialize(provider_repository: ProviderRepository.new,
                       **opts)
          super
          @provider_repository = provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @name = current_user.name
          load_user
          halt_json 404 unless @user
          pp @providers

          self.body = user_json
        end
      end
    end
  end
end
