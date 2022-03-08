module Api
  module Controllers
    module Attrs
      class Show
        include Api::Action

        security_level 5

        params do
          required(:id).filled(:str?)
        end

        def initialize(attr_repository: AttrRepository.new, **opts)
          super(**opts)
          @attr_repository = attr_repository
        end

        def call(params)
          halt_json 400, errors: params.errors unless params.valid?

          @attr = @attr_repository.find_with_mappings_by_name(params[:id])
          halt_json 404 if @attr.nil?

          self.status = 200
          self.body = generate_json(@attr)
        end
      end
    end
  end
end
