# frozen_string_literal: true

require "digest/md5"

module API
  module Actions
    module Adapters
      class Show < API::Action
        include Deps["adapter_repo"]

        params do
          required(:id).filled(:name, max_size?: MAX_STRING_SIZE)
        end

        def handle(request, response)
          check_params(request, response)

          name = request.params[:id]

          adapter = adapter_repo.get!(name)

          response.format = :json
          response.render(view, adapter:)
        end
      end
    end
  end
end
