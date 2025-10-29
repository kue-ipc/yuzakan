# frozen_string_literal: true

require "digest/md5"

module API
  module Actions
    module Adapters
      class Show < API::Action
        include Deps["adapter_map"]

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          check_params(request, response)

          adapter = adapter_map[request.params[:id]]
          halt_json request, response, 404 unless adapter

          response[:adapter] = adapter
        end
      end
    end
  end
end
