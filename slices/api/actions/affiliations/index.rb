# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Index < API::IndexAction
        include Deps["repos.affiliation_repo"]

        security_level 2

        def handle(request, response)
          check_params(request, response)

          page = request.params[:page]
          per_page = request.params[:per_page]
          order = order_from_params(request.params)
          query = query_from_params(request.params)
          filter = filter_from_params(request.params)

          affiliations, pager = affiliation_repo.index(page:, per_page:, order:, query:, filter:)

          response.format = :json
          response[:affiliations] = affiliations
          response[:pager] = pager
        end
      end
    end
  end
end
