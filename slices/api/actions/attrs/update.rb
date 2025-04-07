# frozen_string_literal: true

require_relative "set_attr"

module API
  module Actions
    module Attrs
      class Update < API::Action
        include SetAttr

        security_level 5

        class Params < Hanami::Action::Params
          include Hanami::Validations::Form
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            optional(:name).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            optional(:type).filled(:str?, max_size?: 255)
            optional(:order).filled(:int?)
            optional(:hidden).filled(:bool?)
            optional(:readonly).filled(:bool?)
            optional(:code).maybe(:str?, max_size?: 4096)
            optional(:mappings).each do
              schema do
                predicates NamePredicates
                required(:provider).filled(:str?, :name?, max_size?: 255)
                required(:key).maybe(:str?, max_size?: 255)
                optional(:conversion) do
                  none? | included_in?(AttrMapping::CONVERSIONS)
                end
              end
            end
          end
        end

        params Params

        def initialize(attr_repository: AttrRepository.new,
          attr_mapping_repository: AttrMappingRepository.new,
          provider_repository: ProviderRepository.new,
          **opts)
          super
          @attr_repository ||= attr_repository
          @attr_mapping_repository ||= attr_mapping_repository
          @provider_repository ||= provider_repository
        end

        def handle(_req, _res)
          change_name = params[:name] && params[:name] != @attr.name
          if change_name && @attr_repository.exist_by_name?(params[:name])
            halt_json 422, errors: [{name: [t("errors.uniq?")]}]
          end

          mapping_errors = {}
          mappings_params = (params[:mappings] || []).each_with_index.map { |mapping, idx|
            provider = provider_by_name(mapping[:provider])
            if provider.nil?
              mapping_errors[idx] = {provider: [t("errors.found?")]}
              next
            end

            {**mapping.except(:provider), provider_id: provider&.id}
          }.compact
          unless mapping_errors.empty?
            halt_json 422,
              errors: [{mappings: mapping_errors}]
          end

          @attr_repository.update(@attr.id, params.to_h.except(:id, :mappings))

          mappings_params.each do |mapping_params|
            current_mapping = @attr.mapping_by_provider_id(mapping_params[:provider_id])
            if current_mapping
              if current_mapping.key == mapping_params[:key] &&
                  (!mapping_params.key?(:conversion) || current_mapping.conversion == mapping_params[:conversion])
                next
              end

              @attr_repository.delete_mapping(@attr, current_mapping.id)
            end
            if mapping_params[:key]&.size&.positive?
              @attr_repository.add_mapping(@attr,
                mapping_params)
            end
          end

          @attr = @attr_repository.find_with_mappings(@attr.id)

          self.status = 200
          if change_name
            headers["Content-Location"] =
              routes.attr_path(params[:name])
          end
          self.body = generate_json(@attr, assoc: true)
        end

        private def provider_by_name(name)
          @named_providers ||= @provider_repository.all.to_h { |provider|
            [provider.name, provider]
          }
          @named_providers[name]
        end
      end
    end
  end
end
