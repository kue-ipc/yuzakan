require_relative './connection'

module Web
  module Authorization
    def self.included(action)
      return unless action.is_a?(Class)

      action.class_eval do
        before :authorize!
      end
    end

    include Connection

    private def authorize!
      return reply_unauthorized unless authorized?
    end

    private def authorized?
      !current_user.nil?
      allowed_ip?
    end

    private def allowed_ip?
      return true if allowed_networks.empty?

      result = CheckIp.new(allowed_networks: allowed_networks).call(ip: remote_ip)
      result.successful?
    end

    private def allowed_networks
      current_config.user_networks
    end

    private def reply_unauthorized
      halt 403
    end
  end
end
