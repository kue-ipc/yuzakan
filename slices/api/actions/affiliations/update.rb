# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Update < API::Action
        include Deps[
          "repos.affiliation_repo",
          show_view: "views.affiliations.show"
        ]

        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)
          optional(:name).filled(:name, max_size?: 255)
          optional(:label).value(:str?, max_size?: 255)
          optional(:note).value(:str?, max_size?: 4096)
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          id = request.params[:id]
          name = request.params[:name]

          affiliation =
            affiliation_repo.transaction do
              halt_json request, response, 404 if affiliation_repo.get(id).nil?

              if name && name != id && affiliation_repo.get(name)
                response.flash[:invalid] = {name: [t("errors.uniq?")]}
                halt_json request, response, 422
              end

              affiliation_repo.set(name, **request.params)
            end

          if name && name != id
            response.headers["Content-Location"] = "/api/affiliations/#{affiliation.name}"
            response[:location] = "/api/affiliations/#{affiliation.name}"
          end
          response[:affiliation] = affiliation
          response.render(show_view)
        end
      end
    end
  end
end
