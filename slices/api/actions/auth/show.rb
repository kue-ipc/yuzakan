# frozen_string_literal: true

module API
  module Actions
    module Auth
      class Show < API::Action
        security_level 0
        required_trusted_authentication false

        private def reply_unauthorized(_request, _response)
          halt_json 404
        end

        def handle(_request, response)
          response[:status] = response.status
          response[:auth] = {username: response[:current_user].name}
        end
      end
    end
  end
end
