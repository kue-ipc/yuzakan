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

        contract do
          params do
            required(:category_id).filled(:str?, included_in?: Yuzakan::Relations::Attrs::CATEGORIES)
            required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)
          end

          rule(:id).validate(:name)
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
