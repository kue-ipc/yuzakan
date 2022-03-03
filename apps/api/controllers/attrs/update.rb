module Api
  module Controllers
    module Attrs
      class Update
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            required(:id)
            optional(:name).filled(:str?)
            optional(:label).filled(:str?)
            optional(:type).filled(:str?)
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

        def initialize(attr_repository: AttrRepository.new,
                       attr_mapping_repository: AttrMappingRepository.new,
                       **opts)
          super(**opts)
          @attr_repository = attr_repository
          @attr_mapping_repository = attr_mapping_repository
        end

        def call(params)
          halt_json 400, errors: params.errors unless params.valid? 


          @attr = @attr_repository.find_with_mappings(params[:id])
          halt_json 404 if @attr.nil?



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



          

          pp params.to_h
          self.body = 'OK'
        end
      end
    end
  end
end
