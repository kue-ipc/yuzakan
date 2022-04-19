module Api
  module Controllers
    module Providers
      class Destroy
        include Api::Action

        security_level 5

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

          provider = @provider_repository.find_with_params_by_name(params[:id])
          halt_json 404 if provider.nil?

          @provider_repository.delete(provider.id)

          self.status = 200
          self.body = generate_json({**convert_entity(provider), params: provider.params})
        end
      end
    end
  end
end
