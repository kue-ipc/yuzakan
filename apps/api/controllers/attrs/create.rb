require 'hanami/validations'

module Api
  module Controllers
    module Attrs
      class Create
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:name).filled(:str?, :name?, max_size?: 255)
            required(:label).filled(:str?, max_size?: 255)
            required(:type).filled(:str?)
            optional(:order).maybe(:int?)
            optional(:hidden).maybe(:bool?)
            # rubocop:disable all
            optional(:attr_mappings) { array? { each { schema {
              required(:provider).schema {
                predicates NamePredicates
                required(:name).filled(:str?, :name?, max_size?: 255)
              }
              required(:name).maybe(:str?, max_size?: 255)
              optional(:conversion).maybe(:str?)
            } } } }
            # rubocop:enable all
          end
        end

        params Params

        def initialize(attr_repository: AttrRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super(**opts)
          @attr_repository = attr_repository
          @provider_repository = provider_repository
        end

        def call(params)
          param_errors = only_first_errors(params.errors)
          attr_params = params.to_h.dup

          if !param_errors.key?(:name) && @attr_repository.exist_by_name?(attr_params[:name])
            param_errors[:name] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:label) && @attr_repository.exist_by_label?(attr_params[:label])
            param_errors[:label] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:order) && attr_params[:order] && @attr_repository.exist_by_order?(attr_params[:order])
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

          halt_json(422, errors: [param_errors]) unless param_errors.empty?

          attr_params[:order] ||= @attr_repository.last_order + 8
          @attr = @attr_repository.create_with_mappings(attr_params)

          self.status = 201
          headers['Location'] = routes.attr_path(@attr.id)
          self.body = generate_json(@attr)
        end
      end
    end
  end
end
