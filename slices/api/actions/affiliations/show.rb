# frozen_string_literal: true

module API
  module Actions
    module Affiliations
      class Show < API::Action
        include Deps[
          "repos.affiliation_repo"
        ]

        security_level 1

        params do
          required(:id) { filled(:name, max_size?: 255) | eql?("~") }
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          id = request.params[:id]

          affiliation =
            if id == "~"
              affiliation_repo.find(response[:current_user].affiliation_id)
            else
              affiliation_repo.get(id)
            end

          halt_json request, response, 404 if affiliation.nil?

          response[:affiliation] = affiliation
        end
      end
    end
  end
end
