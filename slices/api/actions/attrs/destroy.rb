# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Destroy < API::Action
        include Deps[
          "repos.attr_repo",
          view: "views.attrs.show",
        ]

        security_level 5

        params do
          required(:category_id).filled(:str?, included_in?: Yuzakan::Relations::Attrs::CATEGORIES)

          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)

          # TODO: category..!!!
          id = take_exist_id(request, response, attr_repo)
          attr = attr_repo.unset(id)

          response[:attr] = attr
        end
      end
    end
  end
end
