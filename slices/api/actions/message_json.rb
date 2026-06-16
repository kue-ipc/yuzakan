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

      private def halt_json(request, response, status, location: nil)
        location ||= request.path
        response.format = :json
        body = response.render(halt_view, status:, location:, current_level: 0)
        halt status, body
      end

      private def redirect_to_json(request, response, url, status: 302)
        response.location = url
        halt_json(request, response, status, location: url)
      end
    end
  end
end
