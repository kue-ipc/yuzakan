require 'hanami/validations'

module Api
  module Controllers
    module Attrs
      class Create
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          class AttrMappingValidator
            include Hanami::Validations

            validations do
              required(:provider_id).filled(:int?)
              required(:name).filled(:str?)
              optional(:conversion).maybe(:str?)
            end
          end

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

        def initialize(attr_repository: AttrRepository.new, **opts)
          super(**opts)
          @attr_repository = attr_repository
        end

        def call(params)
          param_errors = params.errors
          (param_errors[:name] ||= []) << '既に存在します。' if @attr_repository.by_name(params[:name]).exist?
          (param_errors[:label] ||= []) << '既に存在します。' if @attr_repository.by_label(params[:label]).exist?
          halt_json(422, errors: [param_errors]) unless param_errors.empty?

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
