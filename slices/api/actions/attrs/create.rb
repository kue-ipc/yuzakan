# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Create < API::Action
        include Deps[
          "repos.attr_repo",
          "repos.mapping_repo",
          "repos.service_repo",
          view: "views.attrs.show",
        ]

        security_level 5

        contract do
          params do
            required(:category_id).filled(:str?, included_in?: Yuzakan::Relations::Attrs::CATEGORIES)

            required(:name).filled(:str?, max_size?: MAX_STRING_SIZE)
            optional(:label).value(:str?, max_size?: MAX_STRING_SIZE)
            optional(:description).value(:str?, max_size?: MAX_TEXT_SIZE)

            required(:type).filled(:str?, included_in?: Yuzakan::Relations::Attrs::TYPES)

            optional(:order).filled(:int?)
            optional(:hidden).filled(:bool?)
            optional(:readonly).filled(:bool?)

            optional(:code).maybe(:str?, max_size?: MAX_TEXT_SIZE)

            optional(:mappings).array(:hash) do
              required(:service).filled(:str?, max_size?: MAX_STRING_SIZE)
              required(:key).filled(:str?, max_size?: MAX_STRING_SIZE)
              required(:type).filled(:str?, included_in?: Yuzakan::Relations::Mappings::TYPES)
              optional(:params).value(:hash)
            end
          end

          rule(:name).validate(:name)
          rule(mappings: :service).validate(:name)
        end



        def handle(request, response)
          check_params(request, response)

          name = request.params[:name]
          params = request.params.to_h.slice(:label, :description, :type, :hidden, :readonly, :code)
          params[:category] = request.params[:category_id]

          params[:order] = request.params[:order] || next_order

          mappings = take_mappings(request, response) || []

          attr_repo.transaction do
            attr = attr_repo.set!(name, **params)
            attr_repo.renumber_order(attr)
            mappings.each do |mapping_params|
              mapping_repo.create(**mapping_params, attr_id: attr.id)
            end
          end

          attr = get_attr_with_associations(name)

          response.status = :created
          response.headers["Location"] = "/api/attrs/#{name}"
          response.format = :json
          response.render(view, attr:)
        end

        private def next_order
          attr_repo.last_order + 1
        end

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

          halt_json request, response, 422, invalid: {mappings: mapping_errors} unless mapping_errors.empty?

          mappings
        end
      end
    end
  end
end
