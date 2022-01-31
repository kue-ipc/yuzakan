require_relative './connection'

module Web
  module Authorization
    include Connection

    def self.included(action)
      if action.is_a?(Class)
        action.define_singleton_method(:security_level) do |level = nil|
          if level
            @level = level
          else
            @level || default_security_level
          end
        end
        action.define_singleton_method(:default_security_level) { 1 }

        action.class_eval do
          before :authorize!
        end
      else
        action.define_singleton_method(:included, &method(:included))
      end
    end

    private def authorize!
      return reply_unauthorized unless authorized?
    end

    private def authorized?
      allowed_ip? && allowed_user?
      !current_user.nil? && allowed_ip?
    end

    private def allowed_ip?
      return true if allowed_networks.empty?

      result = CheckIp.new(allowed_networks: allowed_networks).call(ip: remote_ip)
      result.successful?
    end

    private def allowed_networks
      if security_level >= 3
        current_config.admin_networks
      else
        current_config.user_networks
      end
    end

    private def allowed_user?
      current_user_level >= security_level
    end

    private def current_user_level
      if current_user&.admin
        5
      elsif current_user
        2
      else
        0
      end
    end

    def security_level
      self.class.security_level
    end

    private def reply_unauthorized
      halt 403
    end
  end
end
