# frozen_string_literal: true

module Api
  module Controllers
    module Providers
      module EntityProvider

        def initialize(provider_repository: ProviderRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
        end

        private def load_provider
          @provider = @provider_repository.find_with_params_by_name(@name)
        end

        private def provider_json
          generate_json(@provider, assoc: current_level >= 5)
        end
      end
    end
  end
end
