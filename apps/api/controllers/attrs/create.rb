require 'hanami/validations'

module Api
  module Controllers
    module Attrs
      class Create
        include Api::Action

        security_level 5

        def initialize(attr_repository: AttrRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super(**opts)
          @attr_repository = attr_repository
          @provider_repository = provider_repository

          @create_attr = CreateAttr.new(attr_repository: @attr_repository,
                                        provider_repository: @provider_repository)
        end

        def call(params)
          result = @create_attr.call(params)

          halt_json(422, errors: merge_errors(result.errors)) if result.failure?

          self.status = 201
          headers['Location'] = routes.attr_path(result.attr.id)
          self.body = generate_json(result.attr)
        end
      end
    end
  end
end
