# frozen_string_literal: true

require_relative './set_attr'

module Api
  module Controllers
    module Attrs
      class Update
        include Api::Action
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
                required(:name).maybe(:str?, max_size?: 255)
                optional(:conversion) { none? | included_in?(AttrMapping::CONVERSIONS) }
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

        def call(params)
          if params[:name] && params[:name] != @attr.name &&
             @attr_repository.exist_by_name?(params[:name])
            halt_json 422, errors: [{name: [I18n.t('errors.uniq?')]}]
          end

          mapping_errors = {}
          mapping_params = (params[:mappings] || []).each_with_index.map do |mapping, idx|
            provider = provider_by_name(mapping[:provider])
            if provider.nil?
              mapping_errors[idx] = {provider: [I18n.t('errors.found?')]}
              next
            end

            {**mapping.except(:provider), provider_id: provider&.id}
          end.compact
          halt_json 422, errors: [{mappings: mapping_errors}] unless mapping_errors.empty?

          @attr_repository.update(@attr.id, params.to_h.except(:id, :mappings))

          mapping_params.each do |m_params|
            current_mapping = @attr.mapping_by_provider_id(m_params[:provider_id])
            if current_mapping
              if current_mapping.name == m_params[:name] &&
                 (!m_params.key?(:conversion) || current_mapping.conversion == m_params[:conversion])
                next
              end

              @attr_repository.delete_mapping(@attr, current_mapping.id)
            end
            @attr_repository.add_mapping(@attr, m_params) if m_params[:name] && !m_params[:name].empty?
          end

          @attr = @attr_repository.find_with_mappings(@attr.id)

          self.status = 200
          self.body = generate_json(@attr, assoc: true)
        end

        private def provider_by_name(name)
          @named_providers ||= @provider_repository.all.to_h { |provider| [provider.name, provider] }
          @named_providers[name]
        end
      end
    end
  end
end
