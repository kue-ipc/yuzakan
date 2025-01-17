# frozen_string_literal: true

require "securerandom"

module Yuzakan
  module Actions
    module Connection
      include CurrentAction

      def self.included(action)
        action.before :connect!
        action.after :done!
      end

      private def connect!(request, response)
        Hanami.logger.info(log_info(request, response))
      end

      private def done!(request, response)
        activity_log_repo.create(**log_info(request, response), status: response[0])
      end

      private def log_info(request, response)
        @log_info ||= {
          uuid: current_uuid(request, response),
          client: request.ip,
          user: current_user(request, response)&.name,
          action: self.class.name,
          method: request.request_method,
          path: request.path,
        }
      end
    end
  end
end
