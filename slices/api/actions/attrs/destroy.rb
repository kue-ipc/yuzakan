# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Destroy < API::Action
        include Deps[
          "repos.attr_repo",
          show_view: "views.attrs.show"
        ]

        security_level 5

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          id = request.params[:id]
          attr = attr_repo.get(id)
          halt_json request, response, 404 unless attr

          # delete attr
          response[:attr] = attr_repo.unset(id)

          response[:attr] = attr
          response.render(show_view)
        end
      end
    end
  end
end
