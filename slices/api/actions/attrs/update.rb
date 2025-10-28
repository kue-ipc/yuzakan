# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Update < API::Action
        include Deps[
          "repos.attr_repo",
          "repos.mapping_repo",
          "repos.service_repo",
          show_view: "views.attrs.show"
        ]

        security_level 5

        params do
          required(:id).filled(:name, max_size?: 255)

          optional(:name).filled(:name, max_size?: 255)
          optional(:label).maybe(:str?, max_size?: 255)
          optional(:description).maybe(:str?, max_size?: 16383)

          optional(:category).filled(:str?, included_in?: Yuzakan::Relations::Attrs::CATEGORIES)
          optional(:type).filled(:str?, included_in?: Yuzakan::Relations::Attrs::TYPES)

          optional(:order).filled(:int?)
          optional(:hidden).filled(:bool?)
          optional(:readonly).filled(:bool?)

          optional(:code).maybe(:str?, max_size?: 16383)

          optional(:mappings).array(:hash) do
            required(:service).filled(:name, max_size?: 255)
            required(:key).filled(:str?, max_size?: 255)
            required(:type).filled(:str?, included_in?: Yuzakan::Relations::Mappings::TYPES)
            optional(:params).value(:hash)
          end
        end

        def handle(request, response)
          check_params(request, response)
          id = take_exist_id(request, response, attr_repo)
          name = take_unique_name(request, response, attr_repo)

          attr = nil
          attr_repo.transaction do
            attr_repo.set(request.params[:id], **request.params.to_h.except(:mappings))
            attr = attr_repo.get_with_mappings_and_services(request.params[:id])

            if (mappings = take_mappings(request, response))
              existing_service_ids = attr.mappings.to_set(&:service_id)

              mappings.each do |m|
                if existing_service_ids.delete?(m[:service_id])
                  # create
                  mapping_repo.create(**m, attr_id: attr.id)
                else
                  # update
                  mapping_repo.update_by_attr_id_and_service_id(attr.id, m[:service_id], **m.except(:service_id))
                end
              end
              # delete
              mapping_repo.delete_by_attr_id_and_service_id(attr.id, existing_service_ids.to_a)
            end
            attr_repo.renumber_order(attr)
          end

          attr = attr_repo.get_with_mappings_and_services(request.params[:id])
          response[:attr] = attr
          response.render(show_view)
        end

        # OPTIMIZE: createにも同じ物があるので、統一したい。
        private def take_mappings(request, response)
          return nil unless request.params[:mappings]

          # NOTE: N+1を避けるためにまとめて取得
          service_map = service_repo.all.to_h { |service| [service.name, service] }

          mapping_errors = {}
          mappings = request.params[:mappings].each_with_index.map do |mapping, idx|
            service = service_map[mapping[:service]]
            if service.nil?
              mapping_errors[idx] = {service: [t("errors.found?")]}
              next
            end

            {**mapping.except(:service), service_id: service&.id}
          end.compact

          unless mapping_errors.empty?
            response.flash[:invalid] = {mappings: mapping_errors}
            halt_json request, response, 422
          end

          mappings
        end
      end
    end
  end
end
