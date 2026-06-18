# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Index < API::IndexAction
        include Deps[
          "repos.affiliation_repo",
        ]

        security_level 2

        def handle(request, response)
          check_params(request, response)

          params = index_params_from_request(request)

          affiliations, pager = affiliation_repo.index(**params)

          response.headers["Total-Count"] = pager.total.to_s
          response.headers["Total-Pages"] = pager.total_pages.to_s
          response.headers["Current-Page"] = pager.current_page.to_s
          response.headers["Per-Page"] = pager.per_page.to_s
          response.format = :json
          response.render(view, affiliations:)
        end
      end
    end
  end
end
