# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Create < API::Action
        include Deps[
          "repos.affiliation_repo",
          view: "views.affiliations.show",
        ]

        security_level 4

        params do
          required(:name).filled(:name, max_size?: MAX_STRING_SIZE)
          optional(:note).value(:str?, max_size?: MAX_TEXT_SIZE)
          optional(:attrs).value(:hash?)
        end

        def handle(request, response)
          check_params(request, response)

          name = request.params[:name]
          params = request.params.to_h.slice(:note, :attrs)
          # TODO: complete_affilationを呼び出してattrsなどを保管する。

          affiliation = affiliation_repo.set!(name, **params)

          response.status = :created
          response.headers["Location"] = "/api/affiliations/#{name}"
          response.format = :json
          response.render(view, affiliation:)
        end
      end
    end
  end
end
