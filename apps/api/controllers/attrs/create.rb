require 'hanami/validations'

module Api
  module Controllers
    module Attrs
      class Create
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            required(:name).filled(:str?)
            required(:label).filled(:str?)
            required(:type).filled(:str?)
            optional(:hidden).maybe(:bool?)
            # rubocop:disable all
            optional(:attr_mappings) { array? { each { schema {
              required(:provider_id).filled(:int?)
              required(:name).filled(:str?)
              optional(:conversion).maybe(:str?)
             } } } }
            # rubocop:enable all
          end
        end

        params Params

        def initialize(attr_repository: AttrRepository.new, **opts)
          super(**opts)
          @attr_repository = attr_repository
        end

        def call(params)
          param_errors = Hash.new { |hash, key| hash[key] = [] }
          param_errors.merge!(params.errors)

          if params[:name] && @attr_repository.by_name(params[:name]).exist?
            param_errors[:name] << I18n.t('errors.uniq?')
          end
          if params[:label] && @attr_repository.by_label(params[:label]).exist?
            param_errors[:label] << I18n.t('errors.uniq?')
          end
          halt_json(422, errors: [param_errors]) unless param_errors.empty?

          attr = @attr_repository.create_with_mappings(params.to_h)

          halt_json 500, '作成時にエラーが発生しました。' unless attr

          self.status = 201
          headers['Location'] = routes.attr_path(attr.id)
          self.body = generate_json(attr)
        end
      end
    end
  end
end
