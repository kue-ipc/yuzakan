module Api
  module Controllers
    module Providers
      class Index
        include Api::Action

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super(**opts)
          @provider_repository = provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @providers = @provider_repository.ordered_all

          self.status = 200
          self.body = generate_json(@providers)
        end
      end
    end
  end
end
