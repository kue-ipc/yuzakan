# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Index < API::Action
        include Deps["repos.attr_repo"]

        params do
          optional(:page).value(:integer, gteq?: 1)
          optional(:per_page).value(:integer, gteq?: 1, lteq?: MAX_PER_PAGE)
        end

        def handle(request, response)
          check_params(request, response)

          attrs =
            if response[:current_level] >= 2
              attr_repo.all(**request.params.to_h.slice(:page, :per_page))
            else
              attr_repo.exposed_all(**request.params.to_h.slice(:page, :per_page))
            end

          response[:attrs] = attrs
        end
      end
    end
  end
end
