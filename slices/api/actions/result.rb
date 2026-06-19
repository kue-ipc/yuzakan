# frozen_string_literal: true

module API
  module Actions
    module Result
      include Dry::Monads[:result]

      private def take_result(request, response, result)
        case result
        in Success[value]
          value
        in Failure[:error, exception]
          halt_json request, response, 500, message: t("errors.internal_server_error"), exception: exception
        in Failure[:failure, message]
          halt_json request, response, 422, message: message
        in Failure[:invalid, validation]
          halt_json request, response, 422, message: t("errors.invalid_params"), invalid: validation
        end
      end
    end
  end
end
