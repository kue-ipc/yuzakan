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
          check_params(request, response)

          id = take_exist_id(request, response, attr_repo)
          attr = attr_repo.unset(id)

          response[:attr] = attr
          response.render(show_view)
        end
      end
    end
  end
end
