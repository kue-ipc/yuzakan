# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Show < API::Action
        include Deps["repos.attr_repo"]

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)

          id = take_exist_id(request, response, attr_repo)
          attr = attr_repo.get_with_mappings_and_services(id)

          response[:attr] = attr
        end
      end
    end
  end
end
