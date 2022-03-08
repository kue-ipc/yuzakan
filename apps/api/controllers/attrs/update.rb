module Api
  module Controllers
    module Attrs
      class Update
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            required(:id).filled(:str?)
            optional(:name).filled(:str?)
            optional(:label).filled(:str?)
            optional(:type).filled(:str?)
            optional(:order).maybe(:int?)
            optional(:hidden).maybe(:bool?)
            # rubocop:disable all
            optional(:attr_mappings) { array? { each { schema {
              required(:provider).schema { required(:name).filled(:str?) }
              required(:name).maybe(:str?)
              optional(:conversion).maybe(:str?)
             } } } }
            # rubocop:enable all
          end
        end

        params Params

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
          halt_json 400, errors: [params.errors.slice(:id)] if params.errors.key?(:id)

          @attr = @attr_repository.find_with_mappings_by_name(params[:id])
          halt_json 404 if @attr.nil?

          param_errors = params.errors.dup
          attr_params = params.to_h.except(:id)

          if !param_errors.key?(:name) && params[:name] && @attr.name != params[:name] &&
             @attr_repository.exist_by_name?(params[:name])
            param_errors[:name] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:label) && params[:label] && @attr.label != params[:label] &&
             @attr_repository.exist_by_label?(attr_params[:label])
            param_errors[:label] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:order) && attr_params[:order] && @attr.order != params[:order] &&
             @attr_repository.exist_by_order?(attr_params[:order])
            param_errors[:order] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:attr_mappings) && attr_params[:attr_mappings]
            providers_by_name = @provider_repository.all.to_h { |provider| [provider.name, provider] }
            idx = 0
            attr_params[:attr_mappings] = attr_params[:attr_mappings].map do |attr_mapping_params|
              provider = providers_by_name[attr_mapping_params.dig(:provider, :name)]
              if provider.nil?
                param_errors[:attr_mappings] ||= {}
                param_errors[:attr_mappings][idx] = {provider: {name: [I18n.t('errors.found?')]}}
              end
              idx += 1
              {**attr_mapping_params.slice(:name, :conversion), provider_id: provider&.id}
            end.reject do |attr_mapping_params|
              attr_mapping_params[:name].nil? || attr_mapping_params[:name].empty?
            end
          end

          halt_json 422, errors: [param_errors] unless param_errors.empty?

          @attr_repository.update(@attr.id, attr_params)

          params[:attr_mappings]&.each do |attr_mapping_params|
            if attr_mapping_params[:name] && !attr_mapping_params[:name].empty?
              existing_attr_mapping = @attr.attr_mappings.find do |mapping|
                mapping.provider_id == attr_mapping_params[:provider_id]
              end
              if existing_attr_mapping
                @attr_mapping_repository.update(existing_attr_mapping.id, attr_mapping_params)
              else
                @attr_repository.add_mapping(@attr, attr_mapping_params)
              end
            else
              @attr_repository.delete_mapping_by_provider_id(@attr, attr_mapping_params[:provider_id])
            end
          end

          updated_attr = @attr_repository.find_with_mappings(@attr.id)

          self.status = 200
          self.body = generate_json(updated_attr)
        end
      end
    end
  end
end
