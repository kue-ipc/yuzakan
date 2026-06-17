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
          required(:name).filled(:name, max_size?: 255)
          optional(:label).value(:str?, max_size?: 255)
          optional(:note).value(:str?, max_size?: 4096)

          optional(:basic).filled(:bool?)
          optional(:prohibited).filled(:bool?)

          opional(:affiliation).maybe(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)
          name = take_unique_name(request, response, group_repo)
          affiliation =
            if request.params[:affiliation]
              affiliation_repo.get(request.params[:affiliation]) ||
                begin
                  halt_json request, response, 422, invalid: {affiliation: t("errors.found?")}
                end
            end

          group = group_repo.set(name,
            **request.params.slice(:label, :note, :basic, :prohibited),
            affiliation_id: affiliation&.id)

          response.status = :created
          response.headers["Content-Location"] = "/api/groups/#{name}"
          response[:location] = "/api/groups/#{name}"
          response[:group] = group
        end
      end
    end
  end
end
