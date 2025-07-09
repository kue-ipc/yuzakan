# frozen_string_literal: true

require_relative "set_attr"

module API
  module Actions
    module Attrs
      class Update < API::Action
        include Deps[
          "repos.attr_repo",
          "repos.mapping_repo",
          "repos.provider_repo",
          show_view: "views.attrs.show"
        ]

        security_level 5

        params do
          required(:id).filled(:name, max_size?: 255)
          optional(:name).filled(:name, max_size?: 255)
          optional(:display_name).maybe(:str?, max_size?: 255)
          optional(:type).filled(:str?, included_in?: Yuzakan::Structs::Attr::TYPES)
          optional(:type).filled(:str?, max_size?: 255)
          optional(:order).filled(:int?)
          optional(:hidden).filled(:bool?)
          optional(:readonly).filled(:bool?)
          optional(:code).maybe(:str?, max_size?: 4096)
          optional(:mappings).array(:hash) do
            required(:provider).filled(:name, max_size?: 255)
            required(:key).maybe(:str?, max_size?: 255)
            optional(:conversion).maybe(included_in?: Yuzakan::Structs::Mapping::CONVERSIONS)
          end
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          id = request.params[:id]
          attr = attr_repo.get(id)
          halt_json request, response, 404 unless attr

          # この間に入れていく

          response[:attr] = attr
          response.render(show_view)

          # TODO: ここから下はまだ見てない

          change_name = params[:name] && params[:name] != @attr.name
          if change_name && @attr_repository.exist_by_name?(params[:name])
            halt_json 422, errors: [{name: [t("errors.uniq?")]}]
          end

          mapping_errors = {}
          mappings_params = (params[:mappings] || []).each_with_index.map do |mapping, idx|
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

          @attr_repository.update(@attr.id, params.to_h.except(:id, :mappings))

          mappings_params.each do |mapping_params|
            current_mapping = @attr.mapping.find_by { |mapping| mapping.provider_id == mapping_params[:provider_id] }
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
          @named_providers ||= @provider_repository.all.to_h do |provider|
            [provider.name, provider]
          end
          @named_providers[name]
        end
      end
    end
  end
end
