# security level
# level 0: anonymous
# level 1: limited user
# level 2: user
# level 3: observer admin
# level 4: operator admin
# level 5: admin

require_relative './connection'

module Web
  module Authorization
    include Connection

    def self.included(action)
      if action.is_a?(Class)
        action.class_eval do
          before :authorize!
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

    private def authorize!
      reply_unauthorized unless authorized?
    end

    private def authorized?
      return true if security_level.zero?

      allowed_ip? && allowed_user?
    end

    private def allowed_ip?
      return true if allowed_networks.nil? || allowed_networks.empty?

      CheckIp.new(allowed_networks: allowed_networks).call(ip: client).successful?
    end

    private def allowed_user?
      (current_user&.clearance_level || 0) >= security_level
    end

    private def reply_unauthorized
      halt 403
    end
  end
end
