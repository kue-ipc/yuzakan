require_relative './set_provider'

module Api
  module Controllers
    module Providers
      class Destroy
        include Api::Action
        include SetProvider

        security_level 5

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super
          @provider_repository ||= provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @provider_repository.delete(@provider.id)

          self.status = 200
          self.body = generate_json(@provider, assoc: true)
        end
      end
    end
  end
end
