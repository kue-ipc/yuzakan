# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Index < API::Action
        include Deps["repos.group_repo", "repos.service_repo"]

        security_level 2

        params do
          optional(:page).value(:integer, gteq?: 1)
          optional(:per_page).value(:integer, gteq?: 1, lteq?: 100)

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

          optional(:primary_only).filled(:bool?)
          optional(:hide_prohibited).filled(:bool?)
          optional(:show_deleted).filled(:bool?)
        end

        def handle(request, response)
          check_params(request, response)

          page = request.params[:page]
          per_page = request.params[:per_page]
          order = order_from_params(request.params)
          query = query_from_params(request.params)
          filter = filter_from_params(request.params)

          relations = group_repo.index(page:, per_page:, order:, query:, filter:)

          response[:groups] = relations.to_a
          response[:pager] = relations.pager
        end

        private def order_from_params(params)
          return nil unless params[:order]

          name, asc_desc = params[:order].split(".", 2).map(&:intern)
          {name => asc_desc || :asc}
        end

        private def query_from_params(params)
          return nil if params[:search].nil? || params[:search].empty?

          search = params[:search].gsub("*", "%").gsub("?", "_")

          case params[:match]
          in :extract
            search
          in :forward
            "#{search}%"
          in :backward
            "%#{search}"
          in :partial
            "%#{search}%"
          end
        end

        private def filter_from_params(params)
          filter = {}
          filter[:primary] = true if params[:primary_only]
          filter[:prohibited] = false if params[:hide_prohibited]
          filter[:deleted] = false unless params[:show_deleted]
          filter
        end
      end
    end
  end
end
