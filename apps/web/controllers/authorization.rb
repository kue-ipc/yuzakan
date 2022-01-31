require_relative './connection'

module Web
  module Authorization
    include Connection

    def self.included(action)
      if action.is_a?(Class)
        action.class_eval do
          before :authorize!
          before :authenticate!
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

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
