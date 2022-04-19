module Api
  module Controllers
    module Providers
      class Check
        include Api::Action

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super
          @provider_repository ||= provider_repository
        end

        def call(params)
          halt_json 400, errors: [params.errors] unless params.valid?

          @provider = @provider_repository.find_with_params_by_name(params[:id])
          halt_json 404 if @provider.nil?

          @provider.check

          self.status = 200
          self.body = generate_json({check: @provider.check})
        end
      end
    end
  end
end
