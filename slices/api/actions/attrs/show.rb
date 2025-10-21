# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Show < API::Action
        include Deps["repos.attr_repo"]

        security_level 1

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)
          attr = get_by_id(request, response, attr_repo)
          response[:attr] = attr
        end
      end
    end
  end
end
