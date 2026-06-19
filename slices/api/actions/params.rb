# frozen_string_literal: true

module API
  module Actions
    module Params
      private def check_params(request, response)
        return if request.params.valid?

        halt_json request, response, 422, message: t("errors.invalid_params"), invalid: request.params.errors
      end
    end
  end
end
