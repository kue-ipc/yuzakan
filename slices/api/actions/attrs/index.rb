# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Index < API::Action
        include Deps["repos.attr_repo"]

        params do
          required(:category_id).filled(:str?, included_in?: Yuzakan::Relations::Attrs::CATEGORIES)
        end

        def handle(request, response)
          check_params(request, response)

          attrs =
            if response[:current_level] >= 2
              attr_repo.all
            else
              attr_repo.exposed_all
            end

          response[:attrs] = attrs
        end
      end
    end
  end
end
