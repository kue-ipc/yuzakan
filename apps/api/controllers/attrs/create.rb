require 'hanami/validations'

module Api
  module Controllers
    module Attrs
      class Create
        include Api::Action

        class AttrMappingValidator
          include Hanami::Validations
          messages_path 'config/messages.yml'

          validations do
            required(:provider_id).filled(:int?)
            required(:name).filled(:str?)
            optional(:conversion).maybe(:str?)
          end
        end

        class Params < Hanami::Action::Params
          messages_path 'config/messages.yml'

          params do
            required(:name).filled(:str?)
            required(:label).filled(:str?)
            required(:type).filled(:str?)
            optional(:hidden).maybe(:bool?)
            optional(:attr_mappings) { array? { each { schema(AttrMappingValidator) } } }
          end
        end

        params Params

        # params_class.class_eval do
        #   # messages :i18n
        # end
        # pp params_class

        def initialize(attr_repository: AttrRepository.new, **opts)
          super(**opts)
          @attr_repository = attr_repository
        end

        def call(params)
          pp params.errors
          halt_json(400, errors: params.errors) unless params.valid?

          data = {
            name: params[:name],
            label: params[:label],
            type: params[:string],
            hidden: nil | params[:hidden],
            order: @attr_repository.last_order + 1,
            attr_mappings: params[:attr_mappings],
          }

          attr = @attr_repository.create_with_mappings(data)

          halt_json 500, '作成時にエラーが発生しました。' unless attr

          self.status = 201
          headers['Location'] = routes.attr_path(attr.id)
          self.body = generate_json(attr)
        end
      end
    end
  end
end
