# frozen_string_literal: true

module API
  module Actions
    module Auth
      class Show < API::Action
        security_level 0
        required_trusted_authentication false

        private def reply_unauthenticated(request, response)
          halt_json request, response, 404, message: t("errors.not_login")
        end

        def handle(_request, response)
          response[:auth] = {username: response[:current_user].name}
        end
      end
    end
  end
end
