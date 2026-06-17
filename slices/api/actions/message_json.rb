# frozen_string_literal: true

require "time"
require "hanami/http/status"

module API
  module Actions
    module MessageJSON
      def self.included(action)
        action.include Deps[
          halt_view: "views.error.halt",
        ]
      end

      private def halt_json(_request, response, status, **opts)
        response.format = :json
        body = response.render(halt_view, status:, error: opts)
        halt status, body
      end
    end
  end
end
