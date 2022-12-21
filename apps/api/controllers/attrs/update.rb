require_relative './set_attr'

module Api
  module Controllers
    module Attrs
      class Update
        include Api::Action
        include SetAttr

        security_level 5

        def initialize(attr_repository: AttrRepository.new,
                       attr_mapping_repository: AttrMappingRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super
          @attr_repository ||= attr_repository
          @attr_mapping_repository ||= attr_mapping_repository
          @provider_repository ||= provider_repository
        end

        def call(params)
          # TODO: ここで完結する
          update_attr = UpdateAttr.new(attr: @attr,
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
