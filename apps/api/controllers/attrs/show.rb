module Api
  module Controllers
    module Attrs
      class Show
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

        def initialize(attr_repository: AttrRepository.new, **opts)
          super(**opts)
          @attr_repository = attr_repository
        end

        def call(params)
          halt_json 400, errors: [params.errors] unless params.valid?

          @attr = @attr_repository.find_with_mappings_by_name(params[:id])
          halt_json 404 if @attr.nil?

          self.status = 200
          self.body = generate_json(@attr)
        end
      end
    end
  end
end
