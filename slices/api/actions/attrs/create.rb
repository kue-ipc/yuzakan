# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Create < API::Action
        include Deps[
          "repos.attr_repo",
          "repos.service_repo",
          show_view: "views.attrs.show"
        ]

        security_level 5

        params do
          required(:name).filled(:name, max_size?: 255)
          optional(:label).maybe(:str?, max_size?: 255)
          required(:type).filled(:str?, included_in?: Yuzakan::Relations::Attrs::TYPES)
          optional(:order).filled(:int?)
          optional(:hidden).filled(:bool?)
          optional(:readonly).filled(:bool?)
          optional(:code).maybe(:str?, max_size?: 4096)
          optional(:mappings).array(:hash) do
            required(:service).filled(:name, max_size?: 255)
            required(:key).filled(:str?, max_size?: 255)
            required(:type).filled(:str?, included_in?: Yuzakan::Relations::Mappings::TYPES)
            optional(:params).value(:hash)
          end
        end

        def handle(request, response)
          check_params(request, response)
          check_unique_name(request, response, attr_repo)

          mappings = take_mappings(request, response)

          attr = attr_repo.create_with_mappings(
            **request.params.to_h.except(:order, :mappings),
            order: request.params[:order] || next_order,
            mappings: mappings)

          response.status = :created
          response.headers["Content-Location"] = "/api/attrs/#{attr.name}"
          response[:location] = "/api/attrs/#{attr.name}"
          response[:attr] = attr
          response.render(show_view)
        end

        private def next_order
          attr_repo.last_order + 1
        end

        private def take_mappings(request, response)
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
