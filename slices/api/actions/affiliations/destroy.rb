# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Destroy < API::Action
        include Deps[
          "repos.affiliation_repo",
          show_view: "views.affiliations.show"
        ]

        security_level 4

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          affiliation = affiliation_repo.get(request.params[:id].to_s)
          halt_json request, response, 404 if affiliation.nil?

          affiliation_repo.unset(affiliation.name)

          response[:affiliation] = affiliation
          response.render(show_view)
        end
      end
    end
  end
end
