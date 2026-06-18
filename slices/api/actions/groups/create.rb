# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Create < API::Action
        include Deps[
          group_repo: "repos.group_repo",
          affiliation_repo: "repos.affiliation_repo",
          view: "views.groups.show",
        ]

        security_level 4

        params do
          required(:name).filled(:name, max_size?: MAX_STRING_SIZE)
          optional(:label).value(:str?, max_size?: MAX_STRING_SIZE)
          optional(:note).value(:str?, max_size?: MAX_TEXT_SIZE)

          optional(:basic).filled(:bool?)
          optional(:prohibited).filled(:bool?)

          opional(:affiliation).maybe(:name, max_size?: MAX_STRING_SIZE)
        end

        def handle(request, response)
          check_params(request, response)

          name = request.params[:name]
          params = request.params.to_h.slice(:label, :note, :basic, :prohibited)
          affiliation = take_affiliation(request, response)

          group = group_repo.set!(name, **params, affiliation_id: affiliation&.id)

          response.status = :created
          response.headers["Location"] = "/api/groups/#{name}"
          response.format = :json
          response.render(view, group:)
        end

        private def take_affiliation(request, response)
          return nil unless request.params[:affiliation]

          affiliation_repo.get!(request.params[:affiliation])
        rescue Yuzakan::DB::Repo::NotFoundNameError
          halt_json request, response, 422, message: t("errors.invalid_params"),
            invalid: {affiliation: t("errors.found?")}
        end
      end
    end
  end
end
