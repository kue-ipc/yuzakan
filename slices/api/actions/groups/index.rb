# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Index < API::IndexAction
        include Deps["repos.group_repo"]

        security_level 2

        params do
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

          groups, pager = group_repo.index(page:, per_page:, order:, query:, filter:)

          response[:groups] = groups
          response[:pager] = pager
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
