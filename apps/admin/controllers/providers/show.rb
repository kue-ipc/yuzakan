module Admin
  module Controllers
    module Providers
      class Show
        include Admin::Action

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name_or_star?, max_size?: 255)
          end
        end

        params Params

        # expose :name

        # def initialize(provider_repository: ProviderRepository.new, **opts)
        #   super(**opts)
        #   @provider_repository = provider_repository
        # end

        def call(params)
          halt 400 unless params.valid?

          # @name = params[:id]

          # @provider = @provider_repository.find_with_params_by_name(params[:id])
          # halt 404 unless @provider

          # halt 400 unless params.valid?

          # @provider = @provider_repository.find_with_adapter(params[:id])

          # halt 404 unless @provider
        end
      end
    end
  end
end
