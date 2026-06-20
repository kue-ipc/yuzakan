# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Update < API::Action
        include Deps[
          "repos.group_repo",
          view: "views.groups.show",
        ]

        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)

          # cannot change name
          # optional(:name).filled(:name, max_size?: 255)
          optional(:label).value(:str?, max_size?: 255)
          optional(:note).value(:str?, max_size?: 4096)

          optional(:basic).filled(:bool?)
          optional(:prohibited).filled(:bool?)

          opional(:affiliation).maybe(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)
          id = take_exist_id(request, response, group_repo)

          update_params = request.params.slice(:label, :note, :basic, :prohibited)
          if request.params.key?(:affiliation)
            if request.params[:affiliation]
              affiliation = affiliation_repo.get(request.params[:affiliation])
              halt_json request, response, 422, invalid: {affiliation: t("errors.found?")} unless affiliation
              update_params[:affiliation_id] = affiliation.id
            else
              update_params[:affiliation_id] = nil
            end
          end

          group = group_repo.put!(id, **update_params)

          response[:group] = group
        end
      end
    end
  end
end
