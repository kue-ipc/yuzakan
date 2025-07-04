# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Index < API::Action
        include Deps["repos.attr_repo"]

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          response[:attrs] = attr_repo.all
        end
      end
    end
  end
end
