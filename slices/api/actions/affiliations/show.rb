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

          affiliation = affiliation_repo.get(request.params[:id].to_s)
          halt_json request, response, 404 if affiliation.nil?

          response[:affiliation] = affiliation
        end
      end
    end
  end
end
