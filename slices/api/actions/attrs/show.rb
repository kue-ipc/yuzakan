# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Show < API::Action
        include Deps["repos.attr_repo"]

        contract do
          params do
            required(:category_id).filled(:str?, included_in?: Yuzakan::Relations::Attrs::CATEGORIES)
            required(:id).filled(:str?, max_size?: MAX_STRING_SIZE)
          end

          rule(:id).validate(:name)
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
