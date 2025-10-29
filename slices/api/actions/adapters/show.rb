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
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          id = request.params[:id]
          adapter = adapter_map[id]
          halt_json request, response, 404 unless adapter

          response[:adapter] = adapter
        end
      end
    end
  end
end
