# frozen_string_literal: true

require_relative "set_attr"

module API
  module Actions
    module Attrs
      class Show < API::Action
        include Deps["repos.attr_repo"]

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          id = request.params[:id]
          attr = attr_repo.get(id)
          halt_json request, response, 404 unless attr

          response[:attr] = attr
        end
      end
    end
  end
end
