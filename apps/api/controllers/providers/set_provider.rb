module Api
  module Controllers
    module Providers
      module SetProvider
        def self.included(action)
          action.class_eval do
            params IdParams
            before :set_provider
          end
        end

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super
          @provider_repository ||= provider_repository
        end

        private def set_provider
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          @provider = @provider_repository.find_with_params_by_name(params[:id])

          halt_json 404 if @provider.nil?
        end
      end
    end
  end
end
