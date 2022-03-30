module Api
  module Controllers
    module Attrs
      module SetAttr
        def self.included(action)
          action.class_eval do
            before :set_attr
          end
        end

        def initialize(attr_repository: AttrRepository.new, **opts)
          super
          @attr_repository ||= attr_repository
        end

        private def set_attr
          id_validation = IdValidations.new(params).validate
          halt_json 400, errors: [id_validation.messages] if id_validation.failure?

          @attr = @attr_repository.find_with_mappings_by_name(params[:id])
          halt_json 404 if @attr.nil?
        end
      end
    end
  end
end
