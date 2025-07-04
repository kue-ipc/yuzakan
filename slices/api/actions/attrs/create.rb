# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Create < API::Action
        include Deps[
          "repos.attr_repo",
          "repos.mapping_repo",
          "repos.provider_repo",
          show_view: "views.attrs.show"
        ]

        security_level 5

        params do
          required(:name).filled(:str?, :name?, max_size?: 255)
          optional(:display_name).maybe(:str?, max_size?: 255)
          required(:type).filled(:str?, included_in?: Yuzakan::Structs::Attr::TYPES)
          optional(:order).filled(:int?)
          optional(:hidden).filled(:bool?)
          optional(:readonly).filled(:bool?)
          optional(:code).maybe(:str?, max_size?: 4096)
          optional(:mappings).array(:hash) do
            required(:provider).filled(:str?, :name?, max_size?: 255)
            required(:key).maybe(:str?, max_size?: 255)
            optional(:conversion).maybe(included_in?: Yuzakan::Structs::Mapping::CONVERSIONS)
          end
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          # TODO: ここから下はまだ見てない

          if @attr_repository.exist_by_name?(params[:name])
            halt_json 422,
              errors: [{name: [t("errors.uniq?")]}]
          end

          mapping_errors = {}
          mappings = (params[:mappings] || []).each_with_index.map do |mapping, idx|
            next if mapping[:key].nil? || mapping[:key].empty?

            provider = provider_by_name(mapping[:provider])
            if provider.nil?
              mapping_errors[idx] = {provider: [t("errors.found?")]}
              next
            end

            {**mapping.except(:provider), provider_id: provider&.id}
          end.compact
          unless mapping_errors.empty?
            halt_json 422,
              errors: [{mappings: mapping_errors}]
          end

          order = params[:order] || (@attr_repository.last_order + 8)
          @attr = @attr_repository.create_with_mappings(
            **params.to_h.except(:mapping),
            order: order,
            mappings: mappings)

          self.status = 201
          headers["Content-Location"] = routes.attr_path(@attr.name)
          self.body = generate_json(@attr, assoc: true)
        end

        private def provider_by_name(name)
          @named_providers ||= @provider_repository.all.to_h do |provider|
            [provider.name, provider]
          end
          @named_providers[name]
        end
      end
    end
  end
end
