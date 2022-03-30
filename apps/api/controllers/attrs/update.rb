module Api
  module Controllers
    module Attrs
      class Update
        include Api::Action

        security_level 5

        def initialize(attr_repository: AttrRepository.new,
                       attr_mapping_repository: AttrMappingRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super(**opts)
          @attr_repository = attr_repository
          @attr_mapping_repository = attr_mapping_repository
          @provider_repository = provider_repository
        end

        def call(params)
          id_validation = IdValidations.new(params).validate
          halt_json 400, errors: [id_validation.messages] if id_validation.failure?

          attr = @attr_repository.find_with_mappings_by_name(params[:id])
          halt_json 404 if attr.nil?

          update_attr = UpdateAttr.new(attr: attr,
                                       attr_repository: @attr_repository,
                                       attr_mapping_repository: @attr_mapping_repository,
                                       provider_repository: @provider_repository)
          result = update_attr.call(params.to_h.except(:id))

          halt_json(422, errors: merge_errors(result.errors)) if result.failure?

          self.status = 200
          self.body = generate_json(result.attr)
        end
      end
    end
  end
end
