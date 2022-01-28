require_relative './connection'

module Web
  module Configuration
    include Connection

    private def configurate!
      return reply_uninitialized unless configurated?
      return reply_maintenance if maintenance?
      return reply_unauthorized_network unless allowed_ip?
    end

    private def configurated?
      !current_config.nil?
    end

    private def maintenance?
      current_config.maintenance
    end

    private def allowed_ip?
      return true if allowed_networks.empty?

      result = CheckIp.new(allowed_networks: allowed_networks).call(ip: remote_ip)
      result.successful?
    end

    private def allowed_networks
      current_config.user_networks
    end

    private def reply_uninitialized
      redirect_to Web.routes.path(:uninitialized)
    end

    private def reply_maintenance
      redirect_to Web.routes.path(:maintenance)
    end

    private def reply_unauthorized_network
      halt 403
    end
  end
end
