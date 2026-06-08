# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Index < API::Action
        include Deps["repos.affiliation_repo"]

        security_level 2

        params do
          optional(:page).value(:integer, gteq?: 1)
          optional(:per_page).value(:integer, gteq?: 1, lteq?: MAX_PER_PAGE)

          optional(:order).filled(:str?, included_in?: %w[
            name
            label
          ].flat_map { |name| [name, "#{name}.asc", "#{name}.desc"] })

          optional(:search).maybe(:str?, max_size?: 255)
          optional(:match).filled(:str?, included_in?: %w[
            extract
            partial
            forward
            backward
          ])
        end

        def handle(request, response)
          check_params(request, response)

          page = request.params[:page]
          per_page = request.params[:per_page]
          order = order_from_params(request.params)
          query = query_from_params(request.params)
          filter = filter_from_params(request.params)

          affiliations, pager = affiliation_repo.index(page:, per_page:, order:, query:, filter:)

          response[:affiliations] = affiliations
          response[:pager] = pager
        end

        private def order_from_params(params)
          return nil unless params[:order]

          name, asc_desc = params[:order].split(".", 2).map(&:intern)
          {name => asc_desc || :asc}
        end

        private def query_from_params(params)
          return nil if params[:search].nil? || params[:search].empty?

          search = params[:search].gsub("*", "%").gsub("?", "_")

          case params[:match]&.intern
          in :extract
            search
          in :forward
            "#{search}%"
          in :backward
            "%#{search}"
          in :partial | nil
            "%#{search}%"
          end
        end

        private def filter_from_params(params)
          nil
        end
      end
    end
  end
end
