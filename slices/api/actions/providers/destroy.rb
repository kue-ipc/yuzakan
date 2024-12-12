# frozen_string_literal: true

require_relative "set_provider"

module Api
  module Actions
    module Providers
      class Destroy < API::Action
        include SetProvider

        security_level 5

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super
          @provider_repository ||= provider_repository
        end

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          @provider_repository.delete(@provider.id)

          self.status = 200
          self.body = provider_json
        end
      end
    end
  end
end
