# frozen_string_literal: true

# security level
# level 0: anonymous
# level 1: limited user
# level 2: user
# level 3: observer admin
# level 4: operator admin
# level 5: admin

module Yuzakan
  module Actions
    module Authorization
      def self.included(action)
        action.before :authorize!
      end

      private def authorize!
        reply_unauthorized unless authorized?
      end

      private def authorized?
        current_level >= security_level
      end

      private def reply_unauthorized
        halt 403
      end
    end
  end
end
