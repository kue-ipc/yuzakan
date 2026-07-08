# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Update < API::Action
        include Deps[
          "management.complete_affiliation",
          "repos.affiliation_repo",
          view: "views.affiliations.show",
        ]

        security_level 4

        contract do
          params do
            required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)
            optional(:note).value(:str?, max_size?: MAX_TEXT_SIZE)
            optional(:attrs).value(:hash?)
          end

          rule(:id).validate(:name)
        end

        def handle(request, response)
          check_params(request, response)

          affiliation = affiliation_repo.get!(request.params[:id])

          note = request.params[:note] || affiliation.note
          result = complete_affiliation.call(affiliation.name, request.params[:attrs] || affiliation.attrs)
          attrs = take_result(request, response, result)

          affiliation = affiliation_repo.put!(affiliation.name, note:, attrs:)

          response.fresh last_modified: affiliation.updated_at
          response.format = :json
          response.render(view, affiliation:)
        end
      end
    end
  end
end
