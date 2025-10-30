# frozen_string_literal: true

require "digest/md5"

module API
  module Actions
    module Adapters
      class Show < API::Action
        include Deps["adapter_repo"]

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)

          id = take_exist_id(request, response, adapter_repo)
          adapter = adapter_repo.get(id)

          response[:adapter] = adapter
        end
      end
    end
  end
end
