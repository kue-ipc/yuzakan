module Api
  module Controllers
    module Attrs
      class Update
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            required(:id).filled(:int?)
            optional(:name).filled(:str?)
            optional(:label).filled(:str?)
            optional(:type).filled(:str?)
            optional(:hidden).maybe(:bool?)
            # rubocop:disable all
            optional(:attr_mappings) { array? { each { schema {
              required(:provider_id).filled(:int?)
              required(:name).maybe(:str?)
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
          halt_json 400, errors: [params.errors.slice(:id)] if !params.valid? && params.errors.has_key(:id)

          @attr = @attr_repository.find_with_mappings(params[:id])
          halt_json 404 if @attr.nil?

          param_errors = Hash.new { |hash, key| hash[key] = [] }
          param_errors.merge!(params.errors) unless params.valid?
          if params[:name] && @attr.name != params[:name] &&
             @attr_repository.by_name(params[:name]).exist?
            param_errors[:name] << I18n.t('errors.uniq?')
          end
          if params[:label] && @attr.label != params[:label] &&
             @attr_repository.by_label(params[:label]).exist?
            param_errors[:label] << I18n.t('errors.uniq?')
          end
          halt_json 422, errors: [param_errors] unless param_errors.empty?

          @attr_repository.update(@attr.id, params.to_h)




          params[:attr_mappings]&.each do |attr_mapping_params|
            p @attr_repository
            attr_mapping = @attr_repository.mapping_by_provider_id(@attr, attr_mapping_params[:provider_id])
            add_or_update = attr_mapping_params[:name] && !attr_mapping_params[:name].empty?
            if attr_mapping
              if add_or_update
                @attr_mapping_repository.update(attr_mapping.id, attr_mapping_params)
              else
                @attr_repository.romve_mapping(@attr, attr_mapping.id)
              end
            elsif add_or_update
              @attr_repository.add_mapping(@attr, attr_mapping_params)
            end
          end

          @attr = @attr_repository.find_with_mappings(@attr.id)

          self.status = 200
          self.body = generate_json(@attr)
        end
      end
    end
  end
end
