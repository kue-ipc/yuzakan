# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Create < API::Action
        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:name).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            required(:type).filled(:str?, included_in?: Attr::TYPES)
            optional(:order).filled(:int?)
            optional(:hidden).filled(:bool?)
            optional(:readonly).filled(:bool?)
            optional(:code).maybe(:str?, max_size?: 4096)
            optional(:mappings).each do
              schema do
                predicates NamePredicates
                required(:provider).filled(:str?, :name?, max_size?: 255)
                required(:key).maybe(:str?, max_size?: 255)
                optional(:conversion).maybe(:str?,
                  included_in?: AttrMapping::CONVERSIONS)
              end
            end
          end
        end

        params Params

        def initialize(attr_repository: AttrRepository.new,
          provider_repository: ProviderRepository.new,
          **opts)
          super
          @attr_repository ||= attr_repository
          @provider_repository ||= provider_repository
        end

        def handle(_req, _res)
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          if @attr_repository.exist_by_name?(params[:name])
            halt_json 422,
              errors: [{name: [t("errors.uniq?")]}]
          end

          mapping_errors = {}
          attr_mappings = (params[:mappings] || []).each_with_index.map { |mapping, idx|
            next if mapping[:key].nil? || mapping[:key].empty?

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

          order = params[:order] || (@attr_repository.last_order + 8)
          @attr = @attr_repository.create_with_mappings(
            **params.to_h.except(:mapping),
            order: order,
            attr_mappings: attr_mappings)

          self.status = 201
          headers["Content-Location"] = routes.attr_path(@attr.name)
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
