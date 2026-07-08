# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Create < API::Action
        include Deps[
          "management.complete_affiliation",
          "repos.affiliation_repo",
          view: "views.affiliations.show",
        ]

        security_level 4

        contract do
          params do
            required(:name).filled(:str?, max_size?: MAX_STRING_SIZE)
            optional(:note).value(:str?, max_size?: MAX_TEXT_SIZE)
            optional(:attrs).value(:hash?)
          end

          rule(:name).validate(:name)
        end

        def handle(request, response)
          check_params(request, response)

          name = request.params[:name]
          note = request.params[:note] || ""
          result = complete_affiliation.call(name, request.params[:attrs] || {})
          attrs = take_result(request, response, result)

          affiliation = affiliation_repo.set!(name, note:, attrs:)

          response.status = :created
          response.headers["Location"] = "/api/affiliations/#{name}"
          response.format = :json
          response.render(view, affiliation:)
        end
      end
    end
  end
end
